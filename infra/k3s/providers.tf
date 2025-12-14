# Déclare les providers nécessaires et leurs sources/versions
terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
      version = "~> 3.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
}

# Configuration du provider Kubernetes
# Il va automatiquement utiliser le kubeconfig généré par 'k3d kubeconfig write'
provider "kubernetes" {
  # Pour un usage local avec k3d, laisser les champs vides est la meilleure pratique,
  # car Terraform cherche les fichiers de configuration par défaut.
}

# Configuration du provider 'null'
provider "null" {}