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


# Ressource pour simuler l'importation de l'image Docker
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


# Ressource pour le déploiement de l'application Kubernetes
resource "null_resource" "k8s_app_deployment" {
  depends_on = [null_resource.k3d_image_import]
  
  triggers = {
    image_tag = var.app_image_tag
  }
  
  provisioner "local-exec" {
    # CORRECTION FINALE : Utiliser des guillemets doubles (") pour la chaîne de commande Bash
    # permet d'inclure l'apostrophe (') sans problème d'échappement.
    command = "echo \"Simuler le déploiement de l'image ${self.triggers.image_tag} sur le cluster ${null_resource.k3s_cluster.triggers.name}\""
    interpreter = ["/bin/bash", "-c"]
  }
}