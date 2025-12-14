# infra/k3s/main.tf
# Configuration de base pour un cluster k3d
terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Variables (si vous en avez)
variable "cluster_name" {
  description = "Nom du cluster k3s à créer"
  type        = string
  default     = "k3d-dev-cluster"
}

# La ressource null_resource permet d'exécuter des commandes locales.
# Elle est utilisée ici pour exécuter le script de provisionnement K3s.
resource "null_resource" "k3s_cluster" {
  triggers = {
    # Changer le nom du cluster force le re-provisionnement
    name = var.cluster_name
  }

  # Provisionnement (Création du cluster)
  provisioner "local-exec" {
    # Utiliser un script shell externe pour la clarté et la gestion des commandes complexes.
    # Exécution du script et passage du nom du cluster comme argument.
    command = "chmod +x create_k3s_cluster.sh && ./create_k3s_cluster.sh ${self.triggers.name}"
    
    # Correction pour les environnements Windows/Git: on filtre les retours chariots (\r)
    interpreter = ["/bin/bash", "-c"]
  }

  # Déprovisionnement (Destruction du cluster)
  provisioner "local-exec" {
    when = destroy
    # Suppression du cluster
    command = "k3d cluster delete ${self.triggers.name} || true"
    interpreter = ["/bin/bash", "-c"]
  }
}

# Resource pour le déploiement de l'application (doit probablement être dans un autre fichier ou module,
# mais je la conserve ici pour l'exemple de la variable d'image).
variable "app_image_tag" {
  description = "Le tag de l'image Docker de l'application à déployer"
  type        = string
}

resource "null_resource" "k8s_app_deployment" {
  triggers = {
    image_tag = var.app_image_tag
  }
  
  # Exemple d'application (à adapter)
  provisioner "local-exec" {
    # Ceci est juste un exemple. Il faudrait utiliser des manifestes Kubernetes (kubectl apply ou helm install) ici.
    command = "echo 'Simuler le déploiement de l'image ${self.triggers.image_tag} sur le cluster ${null_resource.k3s_cluster.triggers.name}'"
  }
}