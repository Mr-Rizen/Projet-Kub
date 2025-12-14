# 1. Déclaration des Providers Requis
# C'est ici que nous disons à Terraform d'utiliser le provider Docker.
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      # Changez cette ligne pour garantir une version récente du Provider
      version = ">= 3.0.0" 
      # J'utilise >= 3.0.0 car ces versions supportent mieux les APIs récentes
    }
  }
}

# 2. Configuration du Provider
# Indique à Terraform comment se connecter à Docker. Par défaut,
# il trouve l'API de Docker Desktop si elle est en cours d'exécution.
provider "docker" {}

# 3. Définition de la Ressource (le conteneur Nginx)
# La ressource principale que nous voulons créer.
resource "docker_container" "tf_web_server" {
  name  = "tf-nginx-demo"
  image = "nginx:latest" # L'image à utiliser
  
  # Mapping des ports : le port interne 80 du conteneur
  # est mappé sur le port 8080 de votre machine Windows.
  ports {
    internal = 80
    external = 8080
  }
}