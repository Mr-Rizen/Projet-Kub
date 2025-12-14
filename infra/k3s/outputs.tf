# infra/k3s/outputs.tf

output "cluster_status" {
  description = "Statut du cluster K3s."
  value       = "Cluster '${var.cluster_name}' créé avec succès."
  depends_on  = [null_resource.k3s_cluster]
}

output "application_url" {
  description = "URL pour accéder à l'application Flask."
  # L'URL utilise le port 8081, qui est mappé vers le NodePort 30080
  value = "http://localhost:8081"
  depends_on = [kubernetes_service.app_service]
}

output "dashboard_url" {
  description = "URL pour accéder au Dashboard Kubernetes (attention, nécessite le token d'accès)."
  # Le Dashboard utilise le port 8080, qui est mappé vers le NodePort 30081
  value = "http://localhost:8080"
  depends_on = [null_resource.k3s_cluster]
}

output "app_image_used" {
  description = "Image Docker déployée."
  value       = var.app_image_tag
}