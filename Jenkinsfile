pipeline {
    agent any

    environment {
        IMAGE_NAME = "kiruba1729/devops-project"          // Docker Hub Image Name
        CONTAINER_NAME = "devops-container"              // Container Name
        DOCKER_HUB_CREDS = 'docker-hub-credentials'      // Jenkins Credentials ID for Docker Hub
        EC2_PUBLIC_IP = "54.243.179.27"                 // Public IP of your EC2 instance
        SSH_KEY = credentials('ssh-private-key')         // Jenkins Credentials ID for SSH private key
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
                    sh 'docker build -t $IMAGE_NAME .' // Build the Docker image
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    withDockerRegistry([credentialsId: DOCKER_HUB_CREDS, url: 'https://index.docker.io/v1/']) {
                        sh 'docker push $IMAGE_NAME' // Push image to Docker Hub
                    }
                }
            }
        }

        stage('Deploy to EC2 using SSH') {
            steps {
                script {
                    // Use SSH to deploy the Docker container on EC2
                    sh """
                    ssh -o StrictHostKeyChecking=no -i $SSH_KEY ec2-user@$EC2_PUBLIC_IP \
                        "docker pull $IMAGE_NAME:latest && \
                         docker stop $CONTAINER_NAME || true && \
                         docker rm $CONTAINER_NAME || true && \
                         docker run -d -p 80:80 --name $CONTAINER_NAME $IMAGE_NAME"
                    """
                }
            }
        }
    }
}
