# Security Groups
data "aws_vpc" "default_vpc" {
  default = true
}

module "ansible_sg" {
  source = "../../modules/security-group"

  name        = "ansible-sg"
  description = "Security group for Ansible"
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress_rules = [
  ]
}

module "nginx_sg" {
  source = "../../modules/security-group"

  name        = "nginx-sg"
  description = "Security group for Nginx"
  vpc_id      = data.aws_vpc.default_vpc.id


  ingress_rules = [
    {
      description = "HTTP from internet"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

module "python_sg" {
  source = "../../modules/security-group"

  name        = "python-sg"
  description = "Security group for Flask"
  vpc_id      = data.aws_vpc.default_vpc.id


  ingress_rules = [
    {
      description        = "Flask from Nginx"
      from_port          = 5000
      to_port            = 5000
      protocol           = "tcp"
      security_group_ids = [module.nginx_sg.id]
    }
  ]
}

module "mariadb_sg" {
  source = "../../modules/security-group"

  name        = "mariadb-sg"
  description = "Security group for mariadb"
  vpc_id      = data.aws_vpc.default_vpc.id


  ingress_rules = [
    {
      description        = "MariaDB from Python"
      from_port          = 3306
      to_port            = 3306
      protocol           = "tcp"
      security_group_ids = [module.python_sg.id]
    }
  ]
}

# Keypair
module "keypair" {
  source = "../../modules/keypair"

  project_name = var.projectName
  output_path = "${path.root}/../../../ansible"
}

module "s3_ansible" {
  source = "../../modules/s3"

  project_name = var.projectName
}

module "iam" {
  source = "../../modules/iam"

  project_name       = var.projectName
  ansible_bucket_arn = module.s3_ansible.bucket_arn
}


# Instances
module "ansible_ec2" {
  source = "../../modules/ec2"

  name                  = var.projectName
  project               = var.projectName
  os                    = "amazonlinux"
  ami_id                = data.aws_ami.amazon_linux_2023.id
  instance_type         = var.instanceType
  key_name              = module.keypair.key_name
  vpc_security_group_ids = [module.ansible_sg.id]
  availability_zone     = var.zone
  iam_instance_profile = module.iam.ec2_instance_profile_name

  root_block_device = {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = file("${path.module}/../../modules/user-data/ansible.sh")
}

module "nginx_ec2" {
  source = "../../modules/ec2"

  name                  = "${var.projectName}-nginx"
  project               = var.projectName
  os                    = "redhat"
  ami_id                = data.aws_ami.redhat_rhel8.id
  instance_type         = var.instanceType
  key_name              = module.keypair.key_name
  vpc_security_group_ids = [module.nginx_sg.id]
  availability_zone     = var.zone

  root_block_device = null
  user_data         = null
}

module "python_ec2" {
  source = "../../modules/ec2"

  name                  = "${var.projectName}-python"
  project               = var.projectName
  os                    = "debian"
  ami_id                = data.aws_ami.debian_12.id
  instance_type         = var.instanceType
  key_name              = module.keypair.key_name
  vpc_security_group_ids = [module.python_sg.id]
  availability_zone     = var.zone

  root_block_device = null
  user_data         = null
}

module "mariadb_ec2" {
  source = "../../modules/ec2"

  name                  = "${var.projectName}-mariadb"
  project               = var.projectName
  os                    = "ubuntu"
  ami_id                = data.aws_ami.ubuntu_24_04.id
  instance_type         = var.instanceType
  key_name              = module.keypair.key_name
  vpc_security_group_ids = [module.mariadb_sg.id]
  availability_zone     = var.zone

  root_block_device = null
  user_data         = null
}
