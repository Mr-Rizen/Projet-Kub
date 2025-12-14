#!/bin/bash
# create_k3s_cluster.sh
set -e

# --- Vérification des dépendances ---
command -v k3d >/dev/null || { echo "❌ k3d introuvable"; exit 1; }
command -v helm >/dev/null || { echo "❌ helm introuvable"; exit 1; }
command -v kubectl >/dev/null || { echo "❌ kubectl introuvable"; exit 1; }

CLUSTER_NAME="k3d-dev-cluster"
DASHBOARD_PORT=8082

echo "--- 1. Nettoyage et Création du Cluster (Simple) ---"
k3d cluster delete "$CLUSTER_NAME" 2>/dev/null || true
# Création simple SANS mapping de port (-p)
k3d cluster create "$CLUSTER_NAME" --servers 1 --wait

echo "--- 2. Installation Dashboard (Helm) ---"
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/ --force-update >/dev/null
helm repo update >/dev/null
# Installation standard en HTTP
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
  --namespace kubernetes-dashboard \
  --create-namespace \
  --set protocolHttp=true \
  --wait

echo "--- 3. Création Admin User ---"
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

echo "--- 4. EXPOSITION DU DASHBOARD (Port-Forward) ---"
# Utilisation du service principal du dashboard pour le port-forward
SVC_NAME="service/kubernetes-dashboard"

echo "Lancement du port-forward en arrière-plan sur 0.0.0.0:$DASHBOARD_PORT..."

# On tue les anciens processus de port-forward (important pour le nettoyage)
pkill -f "kubectl port-forward" || true

# Redirection CRUCIALE : 8082 du conteneur Jenkins vers le port 80 du service Dashboard
# --address 0.0.0.0 permet de rendre le trafic accessible par l'hôte Docker (votre PC)
kubectl port-forward -n kubernetes-dashboard $SVC_NAME $DASHBOARD_PORT:80 --address 0.0.0.0 > /dev/null 2>&1 &
echo $! > /tmp/dashboard_portforward_pid

echo "✅ Cluster prêt. Récupération du Token..."
echo "--------------------------------------------------------"
echo "URL Dashboard : http://localhost:8082"
echo "Token pour se connecter :"
# On attend un peu que le service account soit finalisé
sleep 5
kubectl -n kubernetes-dashboard create token admin-user --duration=24h
echo "--------------------------------------------------------"