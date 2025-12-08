# Documentation References:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair

# Control
resource "aws_key_pair" "key_pairs_ansible" {
  key_name   = "${var.projectName}_keypair"
  public_key = file("C:/Users/Luci/.ssh/id_rsa.pub")
}

# Client
resource "tls_private_key" "client_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "client_keypair" {
  key_name   = "${var.projectName}_client-key"
  public_key = tls_private_key.client_key.public_key_openssh
}

resource "local_file" "client_private_key" {
  filename = "${path.module}/${aws_key_pair.client_keypair.key_name}.pem"
  content  = tls_private_key.client_key.private_key_pem
  file_permission = "0400"
}

