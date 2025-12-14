# infra/k3s/main.tf

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

  # NOTE : L'étape de destruction est commentée. Le cluster restera après le pipeline.
  # provisioner "local-exec" {
  #   when = destroy
  #   command = "k3d cluster delete ${self.triggers.name} || true"
  #   interpreter = ["/bin/bash", "-c"]
  # }
}

# Les ressources k3d_image_import et k8s_app_deployment ont été retirées 
# conformément à l'objectif de n'avoir que le Dashboard fonctionnel.