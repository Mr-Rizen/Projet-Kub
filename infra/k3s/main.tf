# infra/k3s/main.tf

# Configuration du provider 'null'
terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Variable (inutile ici mais gardée pour la compatibilité avec Jenkinsfile)
variable "app_image_tag" {
  description = "Tag de l'image de l'application."
  type        = string
  default     = "kikih/devops-webapp:latest"
}

# Configuration du nom du cluster
variable "cluster_name" {
  description = "Nom du cluster K3d"
  type        = string
  default     = "k3d-dev-cluster"
}

# Ressource pour la création du cluster K3s (avec Dashboard)
resource "null_resource" "k3s_cluster" {
  triggers = {
    name = var.cluster_name
  }

  # Provisionnement (Création du cluster K3d et installation du Dashboard Helm)
  provisioner "local-exec" {
    command = "chmod +x create_k3s_cluster.sh && ./create_k3s_cluster.sh"
    interpreter = ["/bin/bash", "-c"]
  }

  # AUCUN provisioner de destruction : le cluster reste en vie.
}