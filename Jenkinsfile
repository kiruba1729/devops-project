pipeline {
    agent any

    environment {
        IMAGE_NAME = "kiruba1729/devops-project"          // Docker Hub Image Name
        CONTAINER_NAME = "devops-container"              // Container Name
        DOCKER_HUB_CREDS = 'docker-hub-credentials'      // Jenkins Credentials ID for Docker Hub
        AWS_CREDENTIALS = 'aws-credentials'             // Jenkins AWS credentials ID
        EC2_PUBLIC_IP = "54.243.179.27"                 // Public IP of your EC2 instance
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
                    withCredentials([usernamePassword(credentialsId: DOCKER_HUB_CREDS, usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh 'docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD'
                        sh 'docker push $IMAGE_NAME' // Push image to Docker Hub
                    }
                }
            }
        }

        stage('Deploy to EC2 using AWS CLI') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentials', credentialsId: AWS_CREDENTIALS]]) {
                        sh """
                        # Set AWS credentials for AWS CLI
                        export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                        export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                        export AWS_DEFAULT_REGION=us-east-1  # Ensure region matches your EC2 instance region

                        # Pull the latest Docker image on EC2
                        ssh -o StrictHostKeyChecking=no ec2-user@$EC2_PUBLIC_IP \
                            "docker pull $IMAGE_NAME:latest"

                        # Stop and remove the existing container
                        ssh -o StrictHostKeyChecking=no ec2-user@$EC2_PUBLIC_IP \
                            "docker stop $CONTAINER_NAME || true && docker rm $CONTAINER_NAME || true"

                        # Run the new container
                        ssh -o StrictHostKeyChecking=no ec2-user@$EC2_PUBLIC_IP \
                            "docker run -d -p 80:80 --name $CONTAINER_NAME $IMAGE_NAME"
                        """
                    }
                }
            }
        }
    }
}
