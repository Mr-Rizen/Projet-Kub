# main.tf - Fichier de déclaration des ressources

# --- PROVISIONNEMENT K3S (Corrigé: Utilisation de -p au lieu de --ports) ---
resource "null_resource" "k3s_cluster" {
  triggers = { name = var.cluster_name }
  provisioner "local-exec" {
    # CORRECTION ICI : Remplacement de --ports par -p
    command = "k3d cluster create ${self.triggers.name} -p 8081:80@loadbalancer --wait"
  }
  provisioner "local-exec" {
    when = destroy
    command = "k3d cluster delete ${self.triggers.name}"
  }
}

resource "null_resource" "kubeconfig_retrieve" {
  depends_on = [null_resource.k3s_cluster]
  provisioner "local-exec" {
    command = "k3d kubeconfig write ${var.cluster_name}"
  }
}

# --- DÉPLOIEMENT DE L'APPLICATION K8S (Utilise l'image taggée par Jenkins) ---

resource "kubernetes_deployment" "custom_app" {
  depends_on = [null_resource.kubeconfig_retrieve]

  metadata {
    name = "flask-deployment"
    labels = { App = var.app_label }
  }

  spec {
    replicas = var.app_replicas
    selector { match_labels = { App = var.app_label } }
    template {
      metadata { labels = { App = var.app_label } }
      spec {
        container {
          name  = "flask-container"
          # Utilise la variable passée par le Jenkinsfile
          image = var.app_image_tag 
          port { container_port = 5000 } # L'application Flask tourne sur le port 5000
        }
      }
    }
  }
}

resource "kubernetes_service" "app_service" {
  metadata {
    name = "flask-loadbalancer-service"
  }
  spec {
    selector = { App = var.app_label }
    port {
      port        = 80
      target_port = 5000 # Le Service envoie le trafic au port 5000 du Pod Flask
    }
    type = "LoadBalancer" 
  }
}