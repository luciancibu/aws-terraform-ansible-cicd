# Documentation References:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

data "aws_vpc" "default_vpc" {
  default = true
}

# Control Ansible Security Group
resource "aws_security_group" "ansible_sg" {
  name        = "${var.projectName}-sg"
  description = "Security group for Ansible"
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.myIP}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.projectName}-sg"
    Project = var.projectName
  }
}

# NGINX Security Group
resource "aws_security_group" "nginx_sg" {
  name        = "${var.projectName}-nginx-sg"
  description = "Security group for Nginx reverse proxy"
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.ansible_ec2.private_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.projectName}-nginx-sg"
    Project = var.projectName
  }
}


# Python Security Group
resource "aws_security_group" "python_sg" {
  name        = "${var.projectName}-python-sg"
  description = "Security group for Python Flask API"
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress {
    description     = "Access from Nginx"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    cidr_blocks = ["${aws_instance.nginx_ec2.private_ip}/32"]
  }
  
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.ansible_ec2.private_ip}/32"]
  }  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.projectName}-python-sg"
    Project = var.projectName
  }
}


# MariaDB Security Group
resource "aws_security_group" "mariadb_sg" {
  name        = "${var.projectName}-mariadb-sg"
  description = "Security group for MariaDB"
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress {
    description     = "Access from Python"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = ["${aws_instance.python_api.private_ip}/32"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.ansible_ec2.private_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.projectName}-mariadb-sg"
    Project = var.projectName
  }
}
