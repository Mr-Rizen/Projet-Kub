# infra/k3s/main.tf

# Cette configuration se concentre uniquement sur la création du cluster K3s et l'installation du Dashboard.

# Ressource null_resource pour la création du cluster K3s (avec Dashboard)
resource "null_resource" "k3s_cluster" {
  triggers = {
    # Force le re-provisionnement si le nom du cluster change
    name = var.cluster_name
  }

  # 1. Provisionnement (Création du cluster K3d et installation du Dashboard Helm)
  provisioner "local-exec" {
    # Exécution du script shell de création du cluster.
    command = "chmod +x create_k3s_cluster.sh && ./create_k3s_cluster.sh ${self.triggers.name}"
    interpreter = ["/bin/bash", "-c"]
  }

  # NOTE IMPORTANTE : Le provisioner "local-exec" avec when = destroy est intentionnellement retiré.
  # Le cluster K3d sera conservé après l'exécution de 'terraform destroy' ou la fin du pipeline.
}