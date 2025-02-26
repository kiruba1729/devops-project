pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/kiruba1729/devops-project.git'
            }
        }

        stage('Build') {
            steps {
                echo 'Building the application...'
                sh 'docker --version' // Check if Docker is available in Jenkins
                sh 'groups'            // Verify user groups in Jenkins
                sh 'whoami'            // Check if running as 'jenkins' user
                sh 'ls -lah /var/run/docker.sock' // Check permissions on Docker socket
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying the application...'
                sh 'docker ps' // List running containers (should work if permission issue is fixed)
            }
        }
    }
}
