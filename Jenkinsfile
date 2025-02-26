pipeline {
    agent any

    environment {
        IMAGE_NAME = "kiruba1729/devops-project"          // Docker Hub Image Name
        CONTAINER_NAME = "devops-container"              // Container Name
        DOCKER_HUB_CREDS = 'docker-hub-credentials'      // Jenkins Credentials ID for Docker Hub
        AWS_CREDENTIALS = credentials('aws-credentials') // Jenkins AWS credentials
        GITHUB_TOKEN = credentials('github-token')       // Jenkins GitHub token
        EC2_PUBLIC_IP = "54.243.179.27"                 // Public IP of your EC2 instance
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    // Checkout code from GitHub using GitHub Token
                    git credentialsId: 'github-token', url: 'https://github.com/kiruba1729/devops-project.git'
                }
            }
        }

        stage('Validate AWS Credentials') {
            steps {
                script {
                    // Validate AWS credentials
                    sh 'aws sts get-caller-identity'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Ensure Docker is installed and build the Docker image
                    sh 'docker --version' // Check if Docker is available
                    sh 'docker build -t $IMAGE_NAME .' // Build the Docker image
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    // Login to Docker Hub and push the image
                    withDockerRegistry([credentialsId: DOCKER_HUB_CREDS, url: 'https://index.docker.io/v1/']) {
                        sh 'docker push $IMAGE_NAME' // Push image to Docker Hub
                    }
                }
            }
        }

        stage('Deploy to EC2 using AWS CLI') {
            steps {
                script {
                    // Set AWS credentials for CLI access
                    withCredentials([string(credentialsId: 'aws-credentials', variable: 'AWS_ACCESS_KEY_ID'),
                                     string(credentialsId: 'aws-credentials', variable: 'AWS_SECRET_ACCESS_KEY')]) {
                        // Use AWS CLI to deploy the Docker container on EC2
                        sh """
                        # Pull the latest Docker image
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
