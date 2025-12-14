# infra/k3s/main.tf (Corrigé)

# Ressource null_resource pour la création et destruction du cluster K3s
resource "null_resource" "k3s_cluster" {
  triggers = {
    # Changer le nom du cluster force le re-provisionnement
    name = var.cluster_name
  }

  # Provisionnement (Création du cluster)
  provisioner "local-exec" {
    # Exécution du script shell de création du cluster avec le nom du cluster en argument.
    command = "chmod +x create_k3s_cluster.sh && ./create_k3s_cluster.sh ${self.triggers.name}"
    interpreter = ["/bin/bash", "-c"]
  }

  # Déprovisionnement (Destruction du cluster)
  provisioner "local-exec" {
    when = destroy
    # Suppression du cluster
    command = "k3d cluster delete ${self.triggers.name} || true"
    interpreter = ["/bin/bash", "-c"]
  }
}

# Ressource pour le déploiement de l'application
resource "null_resource" "k8s_app_deployment" {
  triggers = {
    image_tag = var.app_image_tag
  }
  
  # TODO: Remplacer ceci par le vrai déploiement K8s (kubectl apply ou helm install)
  provisioner "local-exec" {
    command = "echo 'Simuler le déploiement de l\'image ${self.triggers.image_tag} sur le cluster ${null_resource.k3s_cluster.triggers.name}'"
    interpreter = ["/bin/bash", "-c"]
  }
}