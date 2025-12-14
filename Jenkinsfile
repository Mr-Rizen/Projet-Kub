/**
 * Jenkinsfile pour un pipeline CI/CD de déploiement d'une application
 * Flask sur un cluster K3s/K3d provisionné par Terraform.
 *
 * Ce pipeline suppose que :
 * 1. L'image Jenkins a les outils : Docker CLI, Terraform, k3d, et kubectl.
 * 2. Le conteneur Jenkins est lancé avec le montage du socket Docker (-v /var/run/docker.sock:/var/run/docker.sock).
 */

pipeline {
    // Exécuter sur le nœud Jenkins (notre conteneur personnalisé)
    agent any 
    
    // Déclarer les variables d'environnement
    environment {
        APP_NAME = "devops-webapp"
        // Le Tag inclut le numéro de build de Jenkins (ex: kikih/devops-webapp:7)
        DOCKER_IMAGE = "kikih/${APP_NAME}:${BUILD_NUMBER}"
        // Nom du cluster K3d défini dans infra/k3s/variables.tf
        CLUSTER_NAME = "tf-devops-lab" 
    }

    stages {
        stage('1. Préparation et Build') {
            steps {
                script {
                    echo "Construction de l'image Docker de l'application : ${DOCKER_IMAGE}"
                    // L'étape docker build s'exécute dans le sous-dossier de l'application
                    dir('app/web-app') {
                        // Construire l'image
                        sh "docker build -t ${DOCKER_IMAGE} ." 
                    }
                }
            }
        }

        stage('2. Provisionnement K3s (Terraform)') {
            steps {
                dir('infra/k3s') {
                    echo "Initialisation de Terraform..."
                    // 1. Initialisation (télécharge les providers et crée le lock file)
                    sh 'terraform init' 
                    
                    echo "Création du cluster K3s/K3d via Terraform..."
                    // 2. Création du Cluster K3s et récupération du kubeconfig
                    // Nous ciblons uniquement l'infrastructure (null_resource) pour cette étape
                    sh 'terraform apply -target=null_resource.k3s_cluster -target=null_resource.kubeconfig_retrieve -auto-approve'
                }
            }
        }
        
        stage('3. Import Image to K3d (Local Fix)') {
            steps {
                echo "Importation de l'image Docker dans le cluster K3d..."
                // ÉTAPE CRUCIALE pour les clusters locaux : 
                // k3d ne tire pas l'image depuis Docker Hub/Registry par défaut.
                // Il faut lui injecter l'image que Docker vient de construire.
                sh "k3d image import ${DOCKER_IMAGE} -c ${CLUSTER_NAME}"
            }
        }

        stage('4. Déploiement K8s (Terraform)') {
            steps {
                dir('infra/k3s') {
                    echo "Déploiement de l'application dans le cluster..."
                    // Déploiement du Pod/Service K8s en passant le Tag de l'image
                    // La variable est passée à Terraform via '-var'
                    sh "terraform apply -var='app_image_tag=${DOCKER_IMAGE}' -auto-approve"
                    
                    echo "Déploiement terminé. Vérification de l'URL..."
                    // Affichage de l'URL (via le output.tf)
                    sh 'terraform output application_url' 
                }
            }
        }
    }

    post {
        // La destruction doit toujours être tentée
        always {
            echo "Démarrage du nettoyage de l'infrastructure..."
            // Le dir est essentiel dans le post-build
            dir('infra/k3s') {
                // Nettoyage : Détruire le cluster K3d créé par Terraform
                // La variable par défaut dans variables.tf évite l'erreur "variable manquante" ici
                sh 'terraform destroy -auto-approve'
            }
        }
        success {
            echo "✅ Pipeline Réussi. L'application devrait être accessible sur le port 8081."
        }
        failure {
            echo "❌ Pipeline ÉCHOUÉ. Vérifiez les logs des étapes 1 (Docker) et 2 (Terraform Init)."
        }
    }
}