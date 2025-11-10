provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "app_sg" {
  name = "demo_app"

  # Allow SSH for Ansible
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Web App
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Grafana
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Prometheus
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  # A free-tier-eligible Amazon Linux 2 AMI in us-east-1
  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.app_sg.name]

  # IMPORTANT: Change this to the key pair name you created in the AWS console
  key_name      = "my-aws-key"

  tags = {
    Name = "Demo-Server"
  }
}

# This will print the server's IP address when it's done
output "server_public_ip" {
  value = aws_instance.app_server.public_ip
}
