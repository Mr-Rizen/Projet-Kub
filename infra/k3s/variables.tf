variable "cluster_name" {
    default = "tf-devops-lab"
}

variable "app_replicas" {
    default = 3
}

variable "app_label" {
    default = "flask-web"
}

# Nouvelle variable pour l'image construite par Jenkins
variable "app_image_tag" {
    description = "Le tag de l'image Docker construit par Jenkins (ex: kikih/devops-webapp:1)"
    type        = string
    # CORRECTION : Ajout de la valeur par défaut pour permettre à 'terraform destroy' de s'exécuter sans erreur.
    default     = ""
}