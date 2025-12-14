# infra/k3s/outputs.tf

output "cluster_status" {
  description = "Statut du cluster K3s."
  value       = "Cluster '${var.cluster_name}' créé avec succès."
  depends_on  = [null_resource.k3s_cluster]
}

output "application_url" {
  description = "URL pour accéder à l'application Flask."
  # Application sur Hôte:8081 -> K8s:30080
  value = "http://localhost:8081"
  depends_on = [kubernetes_service.app_service]
}

output "dashboard_url" {
  description = "URL pour accéder au Dashboard Kubernetes (attention, nécessite le token d'accès)."
  # Dashboard sur Hôte:8082 -> K8s:30081 (Évite le conflit avec Jenkins)
  value = "http://localhost:8082"
  depends_on = [null_resource.k3s_cluster]
}

output "app_image_used" {
  description = "Image Docker déployée."
  value       = var.app_image_tag
}