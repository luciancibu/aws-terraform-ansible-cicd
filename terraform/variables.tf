variable "projectName" {
  default = "ansible_cicd"
}

variable "region" {
  default = "us-east-1"
}

variable "zone" {
  default = "us-east-1a"
}

variable "my_ip" {
  default = "188.24.56.231"
}

variable "instanceType" {
  default = "t3.micro"
}

variable "ansible_user_by_os" {
  type        = map(string)
  default = {
    ubuntu       = "ubuntu"
    amazonlinux  = "ec2-user"
    centos       = "centos"
  }
}
