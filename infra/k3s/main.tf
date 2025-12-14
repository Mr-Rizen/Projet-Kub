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
    # Le script 'create_k3s_cluster.sh' gère le 'chmod +x' et toutes les commandes K3d/Helm.
    command = "chmod +x create_k3s_cluster.sh && ./create_k3s_cluster.sh ${self.triggers.name}"
    
    # Assure que le script est exécuté par bash/sh, gérant mieux les chemins et les variables.
    interpreter = ["/bin/bash", "-c"]
  }

  # 2. Déprovisionnement (Destruction du cluster)
  provisioner "local-exec" {
    when = destroy
    # Suppression du cluster K3d. Le "|| true" permet à la destruction de continuer même si k3d échoue.
    command = "k3d cluster delete ${self.triggers.name} || true"
    interpreter = ["/bin/bash", "-c"]
  }
}


# Ressource pour simuler l'importation de l'image Docker
# Cette étape est souvent nécessaire avec K3d pour rendre l'image locale disponible dans le cluster.
resource "null_resource" "k3d_image_import" {
  depends_on = [null_resource.k3s_cluster]

  # Le trigger garantit que l'image est importée à chaque nouveau build.
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
    # CORRECTION de l'échappement : 
    # Le \ avant l'apostrophe dans "l'image" empêche le shell d'interpréter cette apostrophe
    # comme la fin prématurée de la chaîne ('Simuler le déploiement de l').
    command = "echo 'Simuler le déploiement de l\\'image ${self.triggers.image_tag} sur le cluster ${null_resource.k3s_cluster.triggers.name}'"
    interpreter = ["/bin/bash", "-c"]
  }
}