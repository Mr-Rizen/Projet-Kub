# 3. Configuration du Provider Kubernetes
# Il va automatiquement chercher le kubeconfig dans les chemins par défaut
provider "kubernetes" {
  # Pour K3d, l'authentification est gérée par le fichier kubeconfig créé en 1.4
  # Terraform utilise ce fichier pour s'authentifier auprès du cluster K3s.
}