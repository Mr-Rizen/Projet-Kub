# infra/k3s/main.tf

# NOTE : La configuration des providers (terraform { required_providers... })
# a été déplacée ou conservée dans providers.tf.
# Les déclarations de variables ont été déplacées dans variables.tf.

# Ressource pour la création du cluster K3s (avec Dashboard)
resource "null_resource" "k3s_cluster" {
  # Les variables "cluster_name" et "app_image_tag" sont maintenant définies
  # et référencées depuis variables.tf.
  triggers = {
    name = var.cluster_name
  }

  # Provisionnement (Création du cluster K3d et installation du Dashboard Helm)
  provisioner "local-exec" {
    command = "chmod +x create_k3s_cluster.sh && ./create_k3s_cluster.sh"
    interpreter = ["/bin/bash", "-c"]
  }

  # AUCUN provisioner de destruction : le cluster reste en vie.
}