# infra/k3s/variables.tf

# Variables pour le cluster
variable "cluster_name" {
  description = "Nom du cluster k3s à créer"
  type        = string
  default     = "k3d-dev-cluster"
}

# Variable pour le tag de l'image de l'application
variable "app_image_tag" {
  description = "Le tag de l'image Docker de l'application à déployer"
  type        = string
  default     = "kikih/devops-webapp:latest"
}