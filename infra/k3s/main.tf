# infra/k3s/main.tf

resource "null_resource" "k3s_cluster" {
  # Déclenche la création
  triggers = {
    name = var.cluster_name
  }

  # Exécution du script Bash
  provisioner "local-exec" {
    command = "chmod +x create_k3s_cluster.sh && ./create_k3s_cluster.sh"
    interpreter = ["/bin/bash", "-c"]
  }
}