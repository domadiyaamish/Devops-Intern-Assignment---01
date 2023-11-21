# main.tf

provider "aws" {
  region = "ap-south-1"  # Change this to your desired AWS region
}

# Default security group
resource "aws_security_group" "my_security_group" {
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  # Allow outbound SSH
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "my-security-group"
  }
}

# Jenkins Security Group
resource "aws_security_group" "jenkins_cicd" {
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Docker Swarm Security Group
resource "aws_security_group" "Docker_Swarm" {
  ingress {
    from_port   = 2377    # This is the main port for communication between Docker Swarm managers.
    to_port     = 2377
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 7946    # This port is used for communication between nodes for discovery.
    to_port     = 7946
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 4789    # If you are using overlay networks, this port is used for overlay network traffic.
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# EC2 Instances Configuration
locals {
  ec2_instances = [
    {
      name                        = "jenkins-CICD"
      security_group_ids          = [aws_security_group.my_security_group.id, aws_security_group.jenkins_cicd.id]
      associate_public_ip_address = true
    },
    {
      name                        = "docker-manager"
      security_group_ids          = [aws_security_group.my_security_group.id, aws_security_group.Docker_Swarm.id]
      associate_public_ip_address = true
    },
    {
      name                        = "docker-worker-1"
      security_group_ids          = [aws_security_group.my_security_group.id, aws_security_group.Docker_Swarm.id]
      associate_public_ip_address = true
    },
    {
      name                        = "docker-worker-2"
      security_group_ids          = [aws_security_group.my_security_group.id, aws_security_group.Docker_Swarm.id]
      associate_public_ip_address = true
    },
  ]
}

# Create EC2 Instances
resource "aws_instance" "ec2_instances" {
  count         = length(local.ec2_instances)
  ami           = "ami-0287a05f0ef0e9d9a"
  instance_type = "t2.micro"
  key_name      = "poojali"
  associate_public_ip_address = local.ec2_instances[count.index]["associate_public_ip_address"]
  vpc_security_group_ids      = local.ec2_instances[count.index]["security_group_ids"]

  tags = {
    Name = local.ec2_instances[count.index]["name"]
  }
}
