pipeline {
    agent any
    
    environment {
        // Générer un tag d'image unique basé sur le numéro de build de Jenkins
        IMAGE_TAG = "kikih/devops-webapp:${env.BUILD_NUMBER}"
        TERRAFORM_DIR = "infra/k3s"
    }
    
    stages {
        stage('Declarative: Checkout SCM') {
            steps {
                // Le SCM Checkout est souvent exécuté deux fois par Jenkins, mais nécessaire.
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
                    // Optionnel : pousser l'image vers Docker Hub si le cluster K3d n'est pas local.
                    // sh "docker push ${IMAGE_TAG}" 
                }
            }
        }

        stage('2. Provisionnement K3s (Terraform)') {
            steps {
                script {
                    // --- CORRECTION : Installation de Helm si non trouvé ---
                    echo "Vérification et installation de Helm..."
                    sh """
                    if ! command -v helm &> /dev/null
                    then
                        echo "Helm non détecté, installation en cours via curl..."
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
                    
                    echo "Création du cluster K3s/K3d via Terraform..."
                    // On cible explicitement la création du cluster.
                    // On laisse la variable image pour la cohérence, même si main.tf est simplifié.
                    sh "terraform apply -target=null_resource.k3s_cluster -var=app_image_tag=${IMAGE_TAG} -auto-approve"
                }
            }
        }
        
        // Les stages 3 et 4 sont conservés, mais terraform apply n'aura plus rien à faire 
        // car leurs ressources ont été retirées du main.tf, ce qui est l'état souhaité.

        stage('3. Import Image to K3d (Local Fix)') {
            steps {
                dir(TERRAFORM_DIR) {
                    echo "Importation de l'image Docker dans le cluster K3d..."
                    // Cette étape ne fera rien si la ressource est retirée du main.tf
                    sh "terraform apply -target=null_resource.k3d_image_import -var=app_image_tag=${IMAGE_TAG} -auto-approve"
                }
            }
        }

        stage('4. Déploiement K8s (Terraform)') {
            steps {
                dir(TERRAFORM_DIR) {
                    echo "Déploiement de l'application K8s via Terraform..."
                    // Cette étape ne fera rien si la ressource est retirée du main.tf
                    sh "terraform apply -target=null_resource.k8s_app_deployment -var=app_image_tag=${IMAGE_TAG} -auto-approve"
                }
            }
        }
    }
    
    post {
        always {
            echo "Démarrage du nettoyage de l'infrastructure..."
            dir("${TERRAFORM_DIR}") {
                // *** COMMANDE DE DESTRUCTION NEUTRALISÉE POUR GARDER LE CLUSTER UP ***
                // sh "terraform destroy -var=app_image_tag=${IMAGE_TAG} -auto-approve" 
                echo "NOTE : Le cluster K3s/K3d est conservé (destroy désactivé dans Jenkinsfile)."
            }
            echo "Nettoyage terminé."
        }
        success {
            echo "✅ Pipeline RÉUSSI. Le cluster K3s est MAINTENU."
        }
        failure {
            echo "❌ Pipeline ÉCHOUÉ. Vérifiez les logs."
        }
    }
}