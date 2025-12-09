# Documentation References:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
# https://developer.hashicorp.com/terraform/language/provisioners

# Control Ansible
resource "aws_instance" "ansible_ec2" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instanceType
  key_name               = aws_key_pair.key_pairs_ansible.key_name
  vpc_security_group_ids = [aws_security_group.ansible_sg.id]
  availability_zone      = var.zone
  
  root_block_device {
  volume_size = 30     
  volume_type = "gp3"
  delete_on_termination = true
  }

  tags = {
    Name    = "${var.projectName}"
    Project = var.projectName
    os = "amazonlinux"
  }
}

data "archive_file" "ansible_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../ansible"
  output_path = "${path.module}/ansible.zip"
}

resource "aws_ec2_instance_state" "ansible_ec2-state" {
  instance_id = aws_instance.ansible_ec2.id
  state       = "running"
}

# NGINX
resource "aws_instance" "nginx_ec2" {
  ami                    = data.aws_ami.redhat_rhel8.id
  instance_type          = var.instanceType
  key_name               = aws_key_pair.client_keypair.key_name
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  availability_zone      = var.zone

  tags = {
    Name    = "${var.projectName}-nginx"
    Project = var.projectName
    os = "redhat"
  }
}

resource "aws_ec2_instance_state" "nginx_ec2-state" {
  instance_id = aws_instance.nginx_ec2.id
  state       = "running"
}

# Python
resource "aws_instance" "python_api" {
  ami                    = data.aws_ami.debian_12.id
  instance_type          = var.instanceType
  key_name               = aws_key_pair.client_keypair.key_name
  vpc_security_group_ids = [aws_security_group.python_sg.id]
  availability_zone      = var.zone

  tags = {
    Name    = "${var.projectName}-python"
    Project = var.projectName
    os = "debian"
  }
}

resource "aws_ec2_instance_state" "ansible_python_api-state" {
  instance_id = aws_instance.python_api.id
  state       = "running"
}


# MariaDB
resource "aws_instance" "mariadb" {
  ami                    = data.aws_ami.ubuntu_24_04.id
  instance_type          = var.instanceType
  key_name               = aws_key_pair.client_keypair.key_name
  vpc_security_group_ids = [aws_security_group.mariadb_sg.id]
  availability_zone      = var.zone

  tags = {
    Name    = "${var.projectName}-mariadb"
    Project = var.projectName
    os = "ubuntu"
  }
}

resource "aws_ec2_instance_state" "mariadb-state" {
  instance_id = aws_instance.mariadb.id
  state       = "running"
}



