// Définition de l'image de base et du tag pour les étapes Docker/K3s
def DOCKER_IMAGE_NAME = "kikih/devops-webapp" 
def DOCKER_IMAGE_TAG = "${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}" // Utilise le numéro de build de Jenkins

pipeline {
    agent any
    environment {
        # Variable d'environnement pour l'image Docker finale
        IMAGE_TAG = DOCKER_IMAGE_TAG
    }

    stages {
        stage('Declarative: Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('1. Préparation et Build') {
            steps {
                script {
                    echo "Construction de l'image Docker de l'application : ${IMAGE_TAG}"
                }
                dir('app/web-app') {
                    sh "docker build -t ${IMAGE_TAG} ."
                }
            }
        }

        stage('2. Provisionnement K3s (Terraform)') {
            steps {
                dir('infra/k3s') {
                    echo "Initialisation de Terraform..."
                    sh 'terraform init'
                    echo "Création du cluster K3s/K3d via Terraform..."
                    
                    // CORRECTION CLÉ A: Cibler uniquement la création du cluster et fournir une valeur bidon
                    sh "terraform apply -target=null_resource.k3s_cluster -target=null_resource.kubeconfig_retrieve -var=app_image_tag=dummy -auto-approve"
                }
            }
        }
        
        stage('3. Import Image to K3d (Local Fix)') {
            steps {
                script {
                    echo "Importation de l'image Docker dans le cluster K3d pour accessibilité locale..."
                }
                // Exécute la commande de k3d sur l'hôte Jenkins
                sh "k3d image import ${IMAGE_TAG} -c tf-devops-lab"
            }
        }

        stage('4. Déploiement K8s (Terraform)') {
            steps {
                dir('infra/k3s') {
                    echo "Déploiement de l'application dans le cluster..."
                    
                    // CORRECTION CLÉ B: Exécuter le reste de l'infra (Deployment/Service) en fournissant la VRAIE variable
                    sh "terraform apply -var=app_image_tag=${IMAGE_TAG} -auto-approve"
                }
            }
        }
    }

    post {
        always {
            echo "Démarrage du nettoyage de l'infrastructure..."
            dir('infra/k3s') {
                // CORRECTION CLÉ C: Nettoyage complet (destroy) en fournissant la variable requise
                sh "terraform destroy -var=app_image_tag=dummy -auto-approve"
            }
            echo "Nettoyage terminé."
        }
        success {
            echo "✅ Pipeline SUCCÈS. Application disponible sur http://localhost:8081 et Dashboard K8s sur http://localhost:8082."
        }
        failure {
            echo "❌ Pipeline ÉCHOUÉ. Vérifiez les logs."
        }
    }
}