# infra/k3s/providers.tf

# 1. Déclaration des providers requis
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# 2. Configuration du fournisseur Kubernetes
# C'est la partie cruciale qui résout l'erreur "connection refused".
# Elle pointe vers le fichier généré par 'k3d kubeconfig write ${var.cluster_name}'.
provider "kubernetes" {
  config_path = "/root/.config/k3d/kubeconfig-${var.cluster_name}.yaml"
}

# 3. Configuration des autres providers (facultatif mais bonne pratique)
provider "null" {}