
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