pipeline {
    agent any

    environment {
        IMAGE_NAME = "kiruba1729/devops-project"          // Docker Hub Image Name
        CONTAINER_NAME = "devops-container"               // Container Name
        DOCKER_HUB_CREDS = 'docker-hub-credentials'       // Jenkins Credentials ID for Docker Hub
        EC2_SSH_KEY = credentials('new-devops-key')       // ✅ Using NEW SSH Key
        EC2_PUBLIC_IP = "54.243.179.27"                   // Public IP of your EC2 instance
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
                    sh 'docker --version'                 // Check Docker availability
                    sh 'docker build -t $IMAGE_NAME .'   // Build Docker image
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    withDockerRegistry([credentialsId: DOCKER_HUB_CREDS, url: 'https://index.docker.io/v1/']) {
                        sh 'docker push $IMAGE_NAME'      // Push image to Docker Hub
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
                    ssh-keyscan -H $EC2_PUBLIC_IP >> ~/.ssh/known_hosts
                    chmod 600 ~/.ssh/known_hosts

                    # Save the EC2 private key to a file on the Jenkins workspace
                    echo "$EC2_SSH_KEY" > /tmp/new-devops-key.pem
                    chmod 400 /tmp/new-devops-key.pem

                    # Deploy to EC2
                    ssh -i /tmp/new-devops-key.pem ec2-user@$EC2_PUBLIC_IP << EOF
                        docker pull $IMAGE_NAME:latest     # Pull latest image
                        docker stop $CONTAINER_NAME || true
                        docker rm $CONTAINER_NAME || true
                        docker run -d -p 80:80 --name $CONTAINER_NAME $IMAGE_NAME
                    EOF

                    # Clean up private key after use
                    rm -f /tmp/new-devops-key.pem
                    '''
                }
            }
        }
    }
}
