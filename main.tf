terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# -----------------
# Generate a new SSH key pair
# -----------------
resource "tls_private_key" "generated" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated" {
  key_name   = "terraform-ansible-key"
  public_key = tls_private_key.generated.public_key_openssh
}

# Save private key locally
resource "local_file" "private_key" {
  content  = tls_private_key.generated.private_key_pem
  filename = "${path.module}/terraform-ansible-key.pem"
  file_permission = "0400"
}

# -----------------
# Security group
# -----------------
resource "aws_security_group" "ec2_sg" {
  name        = "ansible-demo-sg"
  description = "Allow SSH and HTTP"

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

# -----------------
# EC2 Instances via Module
# -----------------

module "docker_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.6"

  name          = "docker-instance"
  ami           = "ami-02d26659fd82cf299"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
}

module "nginx_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.6"

  name                       = "nginx-instance"
  ami                        = "ami-02d26659fd82cf299"
  instance_type              = "t2.micro"
  key_name                   = aws_key_pair.generated.key_name
  vpc_security_group_ids     = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  root_block_device = [
    {
      volume_size = 15
      volume_type = "gp3"
    }
  ]
}

# -----------------
# Inventory.ini
# -----------------

resource "local_file" "inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    docker_ip = module.docker_instance.public_ip
    nginx_ip  = module.nginx_instance.public_ip
  })
  filename = "${path.module}/inventory.ini"
}

# -----------------
# Clone GitHub Repo (before running Ansible)-----(optional)
# -----------------
resource "null_resource" "clone_repo" {
  provisioner "local-exec" {
    command = <<EOT
      if [ -d "./ansible" ]; then
        git -C ./ansible pull
      else
        git clone https://github.com/<ansible-playbook-repo>.git ./ansible
      fi
    EOT
  }
}

# -----------------
# Run Ansible Playbook from Repo
# -----------------
resource "null_resource" "ansible_provision" {
  depends_on = [module.docker_instance, module.nginx_instance, local_file.inventory]

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini ansible/main.yml --private-key ${path.module}/terraform-ansible-key.pem -u ubuntu"
  }
}

# -----------------
# Outputs
# -----------------
output "docker_instance_ip" {
  value = module.docker_instance.public_ip
}

output "nginx_instance_url" {
  value = "http://${module.nginx_instance.public_ip}"
}
