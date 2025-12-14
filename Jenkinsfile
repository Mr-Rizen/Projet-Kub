pipeline {
    agent any 
    
    environment {
        APP_NAME = "devops-webapp"
        DOCKER_IMAGE = "kikih/${APP_NAME}:${BUILD_NUMBER}"
        // Point crucial : Monter le socket Docker hôte pour que Jenkins puisse créer K3s/les builds Docker
        // Nous conservons DOCKER_HOST ici pour la clarté, mais l'essentiel est le montage -v /var/run/docker.sock
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
                }
            }
        }

        stage('2. Provisionnement K3s (Terraform)') {
            steps {
                dir('infra/k3s') {
                    // 1. Initialisation (télécharge les providers)
                    sh 'terraform init' 
                    // 2. Création du Cluster K3s
                    sh 'terraform apply -target=null_resource.k3s_cluster -target=null_resource.kubeconfig_retrieve -auto-approve'
                }
            }
        }
        
        stage('3. Import Image to K3d (Local Fix)') {
            steps {
                // ÉTAPE CRUCIALE : Injecter l'image construite dans le cluster K3d
                sh "k3d image import ${DOCKER_IMAGE} -c tf-devops-lab"
            }
        }

        stage('4. Déploiement K8s (Terraform)') {
            steps {
                dir('infra/k3s') {
                    // Déploiement de l'application
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
            // Nettoyage
            dir('infra/k3s') {
                sh 'terraform destroy -auto-approve'
            }
        }
    }
}