# infra/k3s/variables.tf

variable "cluster_name" {
  description = "Nom du cluster k3d."
  type        = string
  default     = "tf-devops-lab"
}

variable "app_label" {
  description = "Label utilisé pour identifier les composants de l'application Flask."
  type        = string
  default     = "flask-web"
}

variable "app_image_tag" {
  description = "Tag complet de l'image Docker de l'application à déployer (e.g., kikih/devops-webapp:4)."
  type        = string
}