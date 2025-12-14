// Définition de l'image de base (doit rester en dehors du pipeline)
def DOCKER_IMAGE_NAME = "kikih/devops-webapp" 

pipeline {
    agent any
    
    // BLOC ENVIRONMENT CORRIGÉ pour définir le tag de l'image
    environment {
        // Cette syntaxe est correcte pour les variables d'environnement Jenkins
        IMAGE_TAG = "${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}" 
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
                    echo "Construction de l'image Docker de l'application : ${env.IMAGE_TAG}"
                }
                dir('app/web-app') {
                    // Utilisation de env.IMAGE_TAG pour le build Docker
                    sh "docker build -t ${env.IMAGE_TAG} ."
                }
            }
        }

        stage('2. Provisionnement K3s (Terraform)') {
            steps {
                dir('infra/k3s') {
                    echo "Initialisation de Terraform..."
                    sh 'terraform init'
                    echo "Création du cluster K3s/K3d via Terraform..."
                    
                    // CORRECTION A : Ciblage + Variable dummy pour passer la validation Terraform
                    sh "terraform apply -target=null_resource.k3s_cluster -target=null_resource.kubeconfig_retrieve -var=app_image_tag=dummy -auto-approve"
                }
            }
        }
        
        stage('3. Import Image to K3d (Local Fix)') {
            steps {
                script {
                    echo "Importation de l'image Docker dans le cluster K3d pour accessibilité locale..."
                }
                // Utilisation de env.IMAGE_TAG pour l'import
                sh "k3d image import ${env.IMAGE_TAG} -c tf-devops-lab"
            }
        }

        stage('4. Déploiement K8s (Terraform)') {
            steps {
                dir('infra/k3s') {
                    echo "Déploiement de l'application dans le cluster..."
                    
                    // CORRECTION B : Fournir la VRAIE variable d'image pour le déploiement K8s
                    sh "terraform apply -var=app_image_tag=${env.IMAGE_TAG} -auto-approve"
                }
            }
        }
    }

    post {
        always {
            echo "Démarrage du nettoyage de l'infrastructure..."
            dir('infra/k3s') {
                // CORRECTION C : Variable dummy pour le destroy
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