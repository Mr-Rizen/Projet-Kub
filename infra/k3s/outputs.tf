output "cluster_status" {
  description = "Statut du cluster K3d"
  value       = "Cluster '${var.cluster_name}' créé avec succès."
}

output "application_url" {
  description = "URL pour accéder à l'application déployée"
  # L'application est exposée sur le port 8081 du localhost de l'hôte (Windows/Docker Desktop)
  value       = "http://localhost:8081"
}

output "app_image_used" {
  description = "Tag de l'image de l'application déployée"
  value       = kubernetes_deployment.custom_app.spec[0].template[0].spec[0].container[0].image
}