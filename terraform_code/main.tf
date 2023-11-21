# main.tf

provider "aws" {
  region = "ap-south-1"  # Change this to your desired AWS region
}

# EC2 Instances Configuration
locals {
  ec2_instances = [
    {
      name                        = "jenkins-CICD"
      security_group_ids          = [module.resource.security.jenkins_security_group,module.resource.security.my_security_group]
      associate_public_ip_address = true
    },
    {
      name                        = "docker-manager"
      security_group_ids          = [module.resource.security.docker_swarm_security_group,module.resource.security.my_security_group]
      associate_public_ip_address = true
    },
    {
      name                        = "docker-worker-1"
      security_group_ids          = [module.resource.security.docker_swarm_security_group,module.resource.security.my_security_group]
      associate_public_ip_address = true
    },
    {
      name                        = "docker-worker-2"
      security_group_ids          = [module.resource.security.docker_swarm_security_group,module.resource.security.my_security_group]
      associate_public_ip_address = true
    },
  ]
}

data "aws_ami" "latest_ubuntu" {
  most_recent = true

  owners = ["679593333241"]  # Canonical owner ID for Ubuntu AMIs

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create EC2 Instances
module "ec2_flask_app" {
  source = "./modules/ec2"
  count = length(local.ec2_instances)
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = "t2.micro"
  key_name      = "poojali"
  associate_public_ip_address = local.ec2_instances[count.index]["associate_public_ip_address"]
  vpc_security_group_ids      = local.ec2_instances[count.index]["security_group_ids"]

  tags = {
    Name = local.ec2_instances[count.index]["name"]
  }
}