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
                        # Télécharge et exécute le script officiel d'installation de Helm.
                        # Doit être exécuté avant d'entrer dans le dir Terraform, car le script 
                        # create_k3s_cluster.sh en a besoin pour installer le dashboard.
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
                    // La variable image est passée mais n'est pas encore utilisée par cette ressource.
                    sh "terraform apply -target=null_resource.k3s_cluster -var=app_image_tag=${IMAGE_TAG} -auto-approve"
                }
            }
        }
        
        stage('3. Import Image to K3d (Local Fix)') {
            steps {
                dir(TERRAFORM_DIR) {
                    echo "Importation de l'image Docker dans le cluster K3d..."
                    // On cible l'importation de l'image locale.
                    sh "terraform apply -target=null_resource.k3d_image_import -var=app_image_tag=${IMAGE_TAG} -auto-approve"
                }
            }
        }

        stage('4. Déploiement K8s (Terraform)') {
            steps {
                dir(TERRAFORM_DIR) {
                    echo "Déploiement de l'application K8s via Terraform..."
                    // On cible le déploiement de l'application.
                    sh "terraform apply -target=null_resource.k8s_app_deployment -var=app_image_tag=${IMAGE_TAG} -auto-approve"
                }
            }
        }
    }
    
    post {
        always {
            echo "Démarrage du nettoyage de l'infrastructure..."
            dir("${TERRAFORM_DIR}") {
                // Détruire le cluster. Nous utilisons le tag réel pour la cohérence, même si le destroy l'ignore.
                sh "terraform destroy -var=app_image_tag=${IMAGE_TAG} -auto-approve"
            }
            echo "Nettoyage terminé."
        }
        success {
            echo "✅ Pipeline RÉUSSI. L'application est déployée."
        }
        failure {
            echo "❌ Pipeline ÉCHOUÉ. Vérifiez les logs."
        }
    }
}