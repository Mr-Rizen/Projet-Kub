pipeline {
    // Exécuter sur le master Jenkins (qui est notre conteneur personnalisé avec tous les outils)
    agent any 
    
    // Déclarer les variables d'environnement
    environment {
        APP_NAME = "devops-webapp"
        DOCKER_IMAGE = "kikih/${APP_NAME}:${BUILD_NUMBER}"
        # Point crucial : Monter le socket Docker hôte pour que Jenkins puisse créer K3s/les builds Docker
        DOCKER_HOST = 'unix:///var/run/docker.sock' 
    }

    stages {
        stage('1. Préparation et Build') {
            steps {
                script {
                    echo "Construction de l'image Docker de l'application..."
                    dir('app/web-app') {
                        // Construire l'image et la tagger avec le numéro de build
                        sh "docker build -t ${DOCKER_IMAGE} ." 
                    }
                    // Simuler le PUSH vers Docker Hub (nécessite une connexion/authentification réelle)
                    // sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }

        stage('2. Provisionnement K3s (Terraform)') {
            steps {
                dir('infra/k3s') {
                    // 1. Initialisation (télécharge les providers)
                    sh 'terraform init' 
                    // 2. Création du Cluster K3s (target pour ne pas déployer l'app tout de suite)
                    sh 'terraform apply -target=null_resource.k3s_cluster -target=null_resource.kubeconfig_retrieve -auto-approve'
                }
            }
        }

        stage('3. Configuration (Ansible)') {
            steps {
                echo "Skipping Ansible for this minimal deployment (Pas de VM à configurer ici)"
                // Si vous aviez des tâches, elles seraient ici : 
                // sh 'ansible-playbook -i infra/ansible/inventory.ini infra/ansible/playbook.yml'
            }
        }

        stage('4. Déploiement K8s (Terraform)') {
            steps {
                dir('infra/k3s') {
                    // Déploiement de l'application (le provider Kubernetes est maintenant fonctionnel)
                    // On passe le Tag de l'image construite à l'application K8s via une variable Terraform
                    sh "terraform apply -var='app_image_tag=${DOCKER_IMAGE}' -auto-approve"
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline Réussi. L'application est disponible sur http://localhost:8081."
        }
        always {
            // Nettoyage : Détruire le cluster pour ne pas surcharger Docker Desktop
            dir('infra/k3s') {
                sh 'terraform destroy -auto-approve'
            }
        }
    }
}