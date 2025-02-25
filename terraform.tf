provider "aws" {
  region = "us-east-1"
}

# Fetch latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Security Group for Nginx
resource "aws_security_group" "nginx_sg" {
  name        = "nginx_security_group"
  description = "Allow SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Jenkins
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_security_group"
  description = "Allow SSH and Jenkins UI access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Nginx EC2 Instance
resource "aws_instance" "nginx_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = "devops-nginx-key"
  security_groups = [aws_security_group.nginx_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ec2-user
              newgrp docker
              docker run -d -p 80:80 kiruba1729/nginx-custom:v1
              EOF

  tags = {
    Name = "devops-nginx-server"
  }
}

# Jenkins EC2 Instance
resource "aws_instance" "jenkins_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.medium"
  key_name      = "devops-nginx-key"
  security_groups = [aws_security_group.jenkins_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo su
              sudo yum update -y
              
              # Install Java (Amazon Corretto 8)
              sudo amazon-linux-extras enable corretto8
              sudo yum install -y java-1.8.0-amazon-corretto
              
              # Add Jenkins repository and install Jenkins
              sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
              sudo yum install -y jenkins
              
              # Enable and start Jenkins
              sudo systemctl enable jenkins
              sudo systemctl start jenkins
              EOF

  tags = {
    Name = "devops-jenkins-server"
  }
}

# Elastic IPs for static public IPs
resource "aws_eip" "nginx_eip" {
  instance = aws_instance.nginx_server.id
}

resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.jenkins_server.id
}

output "nginx_public_ip" {
  description = "The public IP address of the Nginx server"
  value       = aws_eip.nginx_eip.public_ip
}

output "jenkins_public_ip" {
  description = "The public IP address of the Jenkins server"
  value       = aws_eip.jenkins_eip.public_ip
}
