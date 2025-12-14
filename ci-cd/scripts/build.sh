#!/bin/bash
# ci-cd/scripts/build.sh

APP_NAME="devops-webapp"
DOCKER_IMAGE="$1" # Tag de l'image passé par Jenkins

echo "--- ÉTAPE 1 : TESTS UNITAIRES ET QUALITÉ DU CODE ---"
# Exécuter les tests unitaires Python (nécessite que pytest soit installé dans le conteneur Jenkins ou que les dépendances soient installées)
# Pour ce lab, supposons qu'il suffit d'appeler l'interpréteur Python :
python3 -m unittest test_app.py

if [ $? -ne 0 ]; then
    echo "!!! ÉCHEC des tests unitaires. Arrêt de la construction. !!!"
    exit 1
fi

echo "--- ÉTAPE 2 : CONSTRUCTION DE L'IMAGE DOCKER ---"
docker build -t "${DOCKER_IMAGE}" .

if [ $? -ne 0 ]; then
    echo "!!! ÉCHEC de la construction de l'image Docker !!!"
    exit 1
fi

echo "--- ÉTAPE 3 : PUSH VERS LE REGISTRE ---"
# Remplacez ceci par votre nom d'utilisateur Docker Hub et assurez-vous que Jenkins est connecté
# docker push "${DOCKER_IMAGE}" 

echo "Artefact (${DOCKER_IMAGE}) construit et prêt pour le déploiement."