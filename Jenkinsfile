pipeline {
    agent any
    
    environment {
        // Tag d'image non utilisé mais conservé pour la structure
        IMAGE_TAG = "kikih/devops-webapp:${env.BUILD_NUMBER}"
        TERRAFORM_DIR = "infra/k3s"
    }
    
    stages {
        stage('Declarative: Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('1. Préparation et Build (Ignorée)') {
            // Cette étape est conservée par souci de propreté mais vous pouvez la retirer si l'image n'est pas nécessaire.
            steps {
                script {
                    echo "Construction de l'image Docker de l'application : ${IMAGE_TAG}"
                }
                dir('app/web-app') {
                    // Simplement construire l'image, sans la pousser (optionnel)
                    sh "docker build -t ${IMAGE_TAG} ."
                }
            }
        }

        stage('2. Provisionnement K3s + Dashboard (Terraform)') {
            steps {
                script {
                    // Nous vérifions si Helm est là pour que le script TF puisse s'exécuter
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
                    // Applique uniquement la ressource de création du cluster.
                    sh "terraform apply -target=null_resource.k3s_cluster -var=app_image_tag=${IMAGE_TAG} -auto-approve"
                }
            }
        }
    }
    
    post {
        always {
            echo "--- Résultat du Pipeline ---"
            dir("${TERRAFORM_DIR}") {
                // *** POINT CLÉ : PAS DE 'terraform destroy' ICI ***
                echo "NOTE : Le cluster K3s/K3d est conservé (destroy désactivé dans Jenkinsfile)."
                echo "Accès Dashboard: http://localhost:8082/"
                // Afficher le token pour la dernière fois (nécessite que kubectl soit disponible sur le runner)
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