pipeline {
    agent any
    
    environment {
        // Tag d'image pour votre application
        IMAGE_TAG = "kikih/devops-webapp:${env.BUILD_NUMBER}"
        TERRAFORM_DIR = "infra/k3s"
    }
    
    stages {
        stage('Declarative: Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('1. Préparation et Build (Application)') {
            steps {
                script {
                    echo "Construction de l'image Docker de l'application : ${IMAGE_TAG}"
                }
                dir('app/web-app') {
                    // Simplement construire l'image
                    sh "docker build -t ${IMAGE_TAG} ."
                }
            }
        }

        stage('2. Provisionnement K3s + Dashboard (Terraform)') {
            steps {
                script {
                    // Assurer l'installation de Helm pour que le script TF puisse s'exécuter
                    echo "Vérification et installation de Helm..."
                    sh """
                    if ! command -v helm &> /dev/null
                    then
                        echo "Helm non détecté, installation en cours..."
                        curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
                        echo "Helm installé."
                    else
                        echo "Helm est déjà installé."
                    fi
                    """
                }
                dir(TERRAFORM_DIR) {
                    echo "Initialisation de Terraform..."
                    sh "terraform init"
                    
                    echo "Création du cluster K3s/K3d et du Dashboard..."
                    // CORRECTION CLÉ : Retrait de l'argument -var=app_image_tag qui n'est plus déclaré.
                    // Exécute le script create_k3s_cluster.sh via null_resource.
                    sh "terraform apply -target=null_resource.k3s_cluster -auto-approve"
                }
            }
        }

        // TODO: Ajoutez ici une étape 3 pour le déploiement de l'application web sur K3s 
        // une fois que le cluster est stable (non inclus ici).
    }
    
    post {
        always {
            echo "--- Résultat du Pipeline ---"
            dir("${TERRAFORM_DIR}") {
                // Le cluster est conservé après le pipeline
                echo "NOTE : Le cluster K3s/K3d est conservé (destroy désactivé dans Jenkinsfile)."
                echo "Accès Dashboard: http://localhost:8082/"
                
                // Tente de récupérer le token. Devrait réussir si le cluster est OK.
                sh "kubectl -n kubernetes-dashboard create token admin-user || echo 'Token non disponible immédiatement, cluster en cours de démarrage.'"
            }
        }
        success {
            echo "✅ Pipeline RÉUSSI. Le cluster K3s est MAINTENU."
        }
        failure {
            echo "❌ Pipeline ÉCHOUÉ. Vérifiez les logs."
        }
    }
}