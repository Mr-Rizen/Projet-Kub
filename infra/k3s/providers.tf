# infra/k3s/providers.tf

terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
      version = "~> 3.0"
    }
  }
  # Ajouter ici une configuration de backend si nécessaire (par exemple, pour stocker le state dans S3 ou Azure)
}