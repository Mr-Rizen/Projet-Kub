# infra/k3s/variables.tf

variable "cluster_name" {
  description = "Nom du cluster"
  type        = string
  default     = "k3d-dev-cluster"
}