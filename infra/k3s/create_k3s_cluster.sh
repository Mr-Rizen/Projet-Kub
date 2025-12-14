#!/bin/bash
# create_k3s_cluster.sh

# Arrête le script immédiatement si une commande échoue
set -e

# Vérification des dépendances (k3d et helm doivent être installés sur le runner Jenkins)
command -v k3d || { echo "Erreur: k3d non trouvé."; exit 1; }
command -v helm || { echo "Erreur: helm non trouvé."; exit 1; }
command -v kubectl || { echo "Erreur: kubectl non trouvé."; exit 1; }

# Nom du cluster
CLUSTER_NAME="k3d-dev-cluster"

echo "--- 1. Nettoyage du cluster précédent (si existant) : $CLUSTER_NAME ---"
# Suppression du cluster existant pour un départ propre
k3d cluster delete "$CLUSTER_NAME" || true

echo "--- 2. Création du cluster K3d : $CLUSTER_NAME ---"
# Création du cluster K3d avec 1 serveur et exposition du port 8082:30082
k3d cluster create "$CLUSTER_NAME" \
  --servers 1 \
  --image rancher/k3s:v1.31.5-k3s1 \
  -p 8082:30082@server:0 \
  --wait

echo "--- 3. Ajout/Mise à jour du dépôt Helm pour le Dashboard ---"
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/ --force-update
helm repo update

echo "--- 4. Installation du Dashboard Kubernetes via Helm ---"
# Installation du Dashboard en utilisant le NodePort 30082
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
  --namespace kubernetes-dashboard \
  --create-namespace \
  --set protocolHttp=true \
  --set service.type=NodePort \
  --set service.nodePort=30082 \
  --wait

echo "--- 5. Configuration de l'accès au Dashboard (Token Admin) ---"
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

# Afficher les informations de connexion
echo "✅ Provisionnement K3s + Dashboard terminé avec succès."
echo "--------------------------------------------------------"
echo "URL du Dashboard : http://localhost:8082/"
echo "Token pour se connecter :"

# Attendre que le ServiceAccount soit prêt pour générer le token
# Ceci aide à éviter l'erreur "serviceaccount/admin-user not found"
sleep 5

# Récupérer le token (cette commande DOIT réussir si le SA a été créé)
kubectl -n kubernetes-dashboard create token admin-user

echo "--------------------------------------------------------"

# Petit délai pour laisser le temps aux services internes de démarrer
sleep 10

echo "Vérification finale de l'état des Pods du Dashboard:"
kubectl get pods -n kubernetes-dashboard