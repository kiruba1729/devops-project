pipeline {
    agent any

    environment {
        IMAGE_NAME = "kiruba1729/devops-project"          // Docker Hub Image Name
        CONTAINER_NAME = "devops-container"               // Container Name
        DOCKER_HUB_CREDS = 'docker-hub-credentials'       // Jenkins Credentials ID for Docker Hub
        EC2_SSH_KEY = credentials('aws-credentials')     // Jenkins Credentials for EC2 SSH Key
        EC2_PUBLIC_IP = "54.243.179.27"                  // Public IP of your EC2 instance
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

        stage('Deploy to EC2') {
            steps {
                script {
                    sh '''
                    # Ensure the .ssh directory exists
                    mkdir -p ~/.ssh

                    # Add the EC2 instance's SSH fingerprint to known_hosts
                    echo "54.243.179.27 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAr8FVQvB6HFd4yFwZTtZnmkRtqlyqGS+2jEsDzwp24fO0ZmgwRZYuHfCrc50WyThDiW9U2Gjr2A1+KmML8ySyRbyZznkZ8h+RJkFzKvfaSHhty6xHlmCVtVzRhjlSzz5+Vmg4jwQWmfvhEvH21bZaY4jF0ROvxZT2TrQ1Ue9vYxyqA4GpLno8CwihYmA9bskLrd9GQ== " >> ~/.ssh/known_hosts

                    # Set the correct permissions for the known_hosts file
                    chmod 600 ~/.ssh/known_hosts

                    # Save the EC2 private key to a file on the Jenkins workspace
                    echo "$EC2_SSH_KEY" > /tmp/aws-credentials.pem
                    chmod 600 /tmp/aws-credentials.pem

                    # Use the private key to SSH into the EC2 instance and deploy the Docker container
                    ssh -i /tmp/aws-credentials.pem ec2-user@$EC2_PUBLIC_IP << EOF
                    docker pull $IMAGE_NAME:latest      // Pull the latest image from Docker Hub
                    docker stop $CONTAINER_NAME || true // Stop container if running
                    docker rm $CONTAINER_NAME || true   // Remove existing container
                    docker run -d -p 80:80 --name $CONTAINER_NAME $IMAGE_NAME // Start container
                    EOF
                    '''
                }
            }
        }
    }
}
