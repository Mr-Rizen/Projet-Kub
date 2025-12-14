# infra/k3s/providers.tf

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.38.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.4"
    }
  }
}

# Configuration explicite pour que Terraform utilise le kubeconfig généré par K3d
provider "kubernetes" {
  # Chemin standard où k3d écrit le kubeconfig (ex: /root/.config/k3d/kubeconfig-tf-devops-lab.yaml)
  config_path = "~/.config/k3d/kubeconfig-${var.cluster_name}.yaml"
}