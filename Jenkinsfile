pipeline {
    // Exécuter sur le master Jenkins (notre conteneur personnalisé avec les outils)
    agent any 
    
    // Déclarer les variables d'environnement
    environment {
        APP_NAME = "devops-webapp"
        // Le Tag inclut le numéro de build de Jenkins (ex: kikih/devops-webapp:1)
        DOCKER_IMAGE = "kikih/${APP_NAME}:${BUILD_NUMBER}"
        // Variable non nécessaire si le conteneur est lancé correctement, mais conservée pour info:
        // DOCKER_HOST = 'unix:///var/run/docker.sock' 
    }

    stages {
        stage('1. Préparation et Build') {
            steps {
                script {
                    echo "Construction de l'image Docker de l'application : ${DOCKER_IMAGE}"
                    dir('app/web-app') {
                        // Construire l'image (nécessite que le conteneur Jenkins ait le Docker CLI)
                        sh "docker build -t ${DOCKER_IMAGE} ." 
                    }
                }
            }
        }

        stage('2. Provisionnement K3s (Terraform)') {
            steps {
                dir('infra/k3s') {
                    // 1. Initialisation (télécharge les providers)
                    sh 'terraform init' 
                    // 2. Création du Cluster K3s (target pour ne créer que l'infra)
                    sh 'terraform apply -target=null_resource.k3s_cluster -target=null_resource.kubeconfig_retrieve -auto-approve'
                }
            }
        }
        
        stage('3. Import Image to K3d (Local Fix)') {
            steps {
                echo "Importation de l'image dans le cluster K3d pour éviter ErrImagePull..."
                // ÉTAPE CRUCIALE : Injecter l'image construite dans le cluster K3d
                sh "k3d image import ${DOCKER_IMAGE} -c tf-devops-lab"
            }
        }

        stage('4. Déploiement K8s (Terraform)') {
            steps {
                dir('infra/k3s') {
                    // Déploiement de l'application en passant le Tag de l'image à Terraform
                    sh "terraform apply -var='app_image_tag=${DOCKER_IMAGE}' -auto-approve"
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline Réussi. L'application est disponible sur http://localhost:8081."
        }
        // Always s'exécute même en cas d'échec (sauf si l'échec est trop précoce)
        always {
            echo "Démarrage du nettoyage de l'infrastructure..."
            dir('infra/k3s') {
                // Nettoyage : Détruire le cluster pour ne pas surcharger Docker Desktop
                sh 'terraform destroy -auto-approve'
            }
        }
    }
}