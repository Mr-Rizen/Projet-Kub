# infra/k3s/main.tf

# ----------------------------------------------------------------------
# 1. PROVISIONNEMENT K3S (Résilience et NodePorts fixes)
# ----------------------------------------------------------------------
resource "null_resource" "k3s_cluster" {
  triggers = {
    name = var.cluster_name
  }
  provisioner "local-exec" {
    command = <<-EOT
      # S'assurer que les commandes sont sur une seule ligne pour éviter les erreurs de parsing shell.
      # L'ajout de '|| true' permet à la suppression de ne pas faire échouer le script si le cluster n'existe pas.
      k3d cluster delete ${self.triggers.name} || true

      # COMMANDE K3D CORRIGÉE (sur une seule ligne)
      k3d cluster create ${self.triggers.name} --servers 3 --image rancher/k3s:v1.31.5-k3s1 -p 8081:30080@server:0 -p 8082:30081@server:0 --wait

      # COMMANDE HELM CORRIGÉE (sur une seule ligne)
      helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --repo https://kubernetes.github.io/dashboard/ --namespace kubernetes-dashboard --create-namespace --set protocolHttp=true --set service.type=NodePort --set service.nodePort=30081 --wait
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "k3d cluster delete ${self.triggers.name}"
  }
}

# Récupération du Kubeconfig (nécessaire pour le provider Kubernetes)
resource "null_resource" "kubeconfig_retrieve" {
  depends_on = [null_resource.k3s_cluster]
  provisioner "local-exec" {
    command = "k3d kubeconfig write ${var.cluster_name}"
  }
}

# ----------------------------------------------------------------------
# 2. DÉPLOIEMENT KUBERNETES
# ----------------------------------------------------------------------

# 2.1. Deployment de l'application Flask (3 réplicas)
resource "kubernetes_deployment" "custom_app" {
  depends_on = [null_resource.kubeconfig_retrieve]
  metadata {
    name = "flask-deployment"
    labels = {
      App = var.app_label
    }
  }
  spec {
    replicas = 3 
    selector {
      match_labels = {
        App = var.app_label
      }
    }
    template {
      metadata {
        labels = {
          App = var.app_label
        }
      }
      spec {
        container {
          name  = "flask-container"
          image = var.app_image_tag
          port {
            container_port = 5000 # Port interne de l'application Flask
          }
        }
      }
    }
  }
}

# 2.2. Service NodePort pour l'exposition de l'application Flask (FIX du timeout)
resource "kubernetes_service" "app_service" {
  depends_on = [kubernetes_deployment.custom_app]
  metadata {
    name = "flask-nodeport-service"
  }
  spec {
    selector = {
      App = var.app_label
    }
    # Utilisation de NodePort pour corriger le problème de LoadBalancer
    type = "NodePort" 
    port {
      port        = 80
      target_port = "5000"
      node_port   = 30080 # Le port externe (NodePort) est 30080 (mappé à 8081 sur l'hôte)
      protocol    = "TCP"
    }
  }
}