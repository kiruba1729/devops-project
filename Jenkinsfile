pipeline {
    agent any

    environment {
        IMAGE_NAME = "kiruba1729/devops-app"
        CONTAINER_NAME = "devops-container"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/kiruba1729/devops-project.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker --version' // Check if Docker is available
                    sh 'groups' // Verify user groups
                    sh 'whoami' // Check running user
                    sh 'ls -lah /var/run/docker.sock' // Check permissions
                    sh 'docker build -t $IMAGE_NAME .'
                }
            }
        }

        stage('Run Container') {
            steps {
                script {
                    sh 'docker ps' // Verify running containers
                    sh 'docker stop $CONTAINER_NAME || true'
                    sh 'docker rm $CONTAINER_NAME || true'
                    sh 'docker run -d --name $CONTAINER_NAME -p 8080:80 $IMAGE_NAME'
                }
            }
        }
    }
}
