provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "bastion_vm" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  tags = {
    Name = "bastion-vm"
  }
}

resource "aws_security_group" "ssh_access" {
  name        = "allow_ssh"
  description = "Permite solo SSH desde la IP de gestión"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "default" {
  default = true
}
