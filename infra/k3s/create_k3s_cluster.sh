#!/bin/bash
# create_k3s_cluster.sh

# Arrête le script immédiatement si une commande échoue
set -e

# ... (Vérifications des dépendances - Lignes 8 à 15 inchangées) ...

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
# Création du cluster K3d avec 3 serveurs et les ports exposés
k3d cluster create "$CLUSTER_NAME" \
  --servers 3 \
  --image rancher/k3s:v1.31.5-k3s1 \
  -p 8081:30080@server:0 \
  -p 8082:30082@server:0 \
  --wait
# REMARQUE :
# 1. 8081 (hôte) redirige vers 30080 (cluster) -> Pour votre application.
# 2. 8082 (hôte) redirige vers 30082 (cluster) -> Pour le Dashboard.

echo "--- 3. Ajout du dépôt Helm pour le Dashboard ---"
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

echo "--- 4. Installation du Dashboard Kubernetes via Helm ---"
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
  --namespace kubernetes-dashboard \
  --create-namespace \
  --set protocolHttp=true \
  --set service.type=NodePort \
  --set service.nodePort=30082 \
  --wait
# NOTE : Le NodePort du Dashboard est maintenant 30082, ce qui correspond à la redirection ci-dessus.

echo "✅ Provisionnement K3s terminé avec succès."