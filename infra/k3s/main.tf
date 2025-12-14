# infra/k3s/main.tf
# Ce fichier contient uniquement la définition des ressources.
# La configuration des providers et des variables doit être dans providers.tf et variables.tf.

# Ressource null_resource pour la création et destruction du cluster K3s
resource "null_resource" "k3s_cluster" {
  triggers = {
    # Force le re-provisionnement si le nom du cluster change
    name = var.cluster_name
  }

  # 1. Provisionnement (Création du cluster K3d et installation du Dashboard Helm)
  provisioner "local-exec" {
    # Exécution du script shell de création du cluster.
    command = "chmod +x create_k3s_cluster.sh && ./create_k3s_cluster.sh ${self.triggers.name}"
    interpreter = ["/bin/bash", "-c"]
  }

  # 2. Déprovisionnement (Destruction du cluster)
  provisioner "local-exec" {
    when = destroy
    # Suppression du cluster K3d.
    command = "k3d cluster delete ${self.triggers.name} || true"
    interpreter = ["/bin/bash", "-c"]
  }
}


# Ressource pour l'importation de l'image Docker dans le cluster K3d
resource "null_resource" "k3d_image_import" {
  depends_on = [null_resource.k3s_cluster]

  triggers = {
    image_tag = var.app_image_tag
    cluster_name = var.cluster_name
  }

  provisioner "local-exec" {
    command = "k3d image import ${self.triggers.image_tag} -c ${self.triggers.cluster_name}"
    interpreter = ["/bin/bash", "-c"]
  }
}


# Ressource pour le déploiement de l'application Kubernetes (MAJ pour déploiement réel)
resource "null_resource" "k8s_app_deployment" {
  depends_on = [null_resource.k3d_image_import]
  
  triggers = {
    image_tag = var.app_image_tag
    cluster_name = null_resource.k3s_cluster.triggers.name 
  }
  
  provisioner "local-exec" {
    # Définir le répertoire de travail pour accéder aux fichiers YAML
    working_dir = "${path.module}/../../app/kubernetes"

    command = <<EOT
      # 1. Remplacer le placeholder LATEST_TAG par le tag réel de l'image
      sed "s|kikih/devops-webapp:LATEST_TAG|${self.triggers.image_tag}|g" deployment.yaml > deployment-temp.yaml

      echo "Déploiement de l'image ${self.triggers.image_tag} sur le cluster ${self.triggers.cluster_name}..."

      # 2. Appliquer les manifestes (Déploiement et Service) via kubectl
      kubectl apply -f deployment-temp.yaml
      kubectl apply -f service.yaml

      echo "✅ Déploiement Kubernetes appliqué avec succès."
      
      # 3. Nettoyage du fichier temporaire
      rm deployment-temp.yaml
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}