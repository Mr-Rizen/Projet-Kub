#!/bin/bash
# create_k3s_cluster.sh

# Arrête le script immédiatement si une commande échoue
set -e

# Vérification des dépendances (meilleure pratique)
command -v k3d || { echo "k3d non trouvé. Assurez-vous qu'il est installé."; exit 1; }
command -v helm || { echo "helm non trouvé. Assurez-vous qu'il est installé."; exit 1; }

# Récupération de l'argument (nom du cluster)
CLUSTER_NAME=$1
if [ -z "$CLUSTER_NAME" ]; then
    echo "Erreur: Le nom du cluster doit être fourni comme argument."
    exit 1
fi

echo "--- 1. Nettoyage du cluster précédent (si existant) : $CLUSTER_NAME ---"
# Suppression du cluster existant pour un départ propre
k3d cluster delete "$CLUSTER_NAME" || true

echo "--- 2. Création du cluster K3d : $CLUSTER_NAME ---"
# Création du cluster K3d avec 1 serveur et SEULEMENT le port du Dashboard exposé
k3d cluster create "$CLUSTER_NAME" \
  --servers 1 \
  --image rancher/k3s:v1.31.5-k3s1 \
  -p 8082:30082@server:0 \
  --wait
# NOTE: 8082 (hôte) est redirigé vers 30082 (NodePort du Dashboard).

echo "--- 3. Ajout du dépôt Helm pour le Dashboard ---"
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/ --force-update

echo "--- 4. Installation du Dashboard Kubernetes via Helm ---"
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
  --namespace kubernetes-dashboard \
  --create-namespace \
  --set protocolHttp=true \
  --set service.type=NodePort \
  --set service.nodePort=30082 \
  --wait

echo "--- 5. Configuration de l'accès au Dashboard (Token) ---"
# Création d'un ServiceAccount et d'un ClusterRoleBinding pour l'accès complet
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

echo "✅ Provisionnement K3s + Dashboard terminé avec succès."
echo "--------------------------------------------------------"
echo "URL du Dashboard : http://localhost:8082/"
echo "Token pour se connecter : (attendez quelques secondes pour l'apparition)"
kubectl -n kubernetes-dashboard create token admin-user
echo "--------------------------------------------------------"