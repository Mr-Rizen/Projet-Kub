# infra/k3s/outputs.tf

output "dashboard_url" {
  description = "URL d'accès au Dashboard"
  value       = "http://localhost:8082"
}

output "token_info" {
  description = "Où trouver le token ?"
  value       = "Le token de connexion est affiché dans la console Jenkins après le lancement de 'create_k3s_cluster.sh'."
}