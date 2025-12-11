# Public IPs od EC2 Instances
output "ansible_public_ip" {
  description = "Public IP of the Ansible"
  value       = aws_instance.ansible_ec2.public_ip
}

output "nginx_public_ip" {
  description = "Public IP of the Nginx reverse proxy EC2"
  value       = aws_instance.nginx_ec2.public_ip
}

output "python_public_ip" {
  description = "Public IP of the Python Flask EC2"
  value       = aws_instance.python_api.public_ip
}

output "mariadb_public_ip" {
  description = "Public IP of the Node.js EC2"
  value       = aws_instance.mariadb.public_ip
}

# Private IPs of EC2 Instances
output "ansible_private_ip" {
  description = "Private IP of the Ansible EC2"
  value       = aws_instance.ansible_ec2.private_ip
}

output "nginx_private_ip" {
  description = "Private IP of the Nginx EC2"
  value       = aws_instance.nginx_ec2.private_ip
}

output "python_private_ip" {
  description = "Private IP of the Python Flask EC2"
  value       = aws_instance.python_api.private_ip
}

output "mariadb_private_ip" {
  description = "Private IP of the Node.js EC2"
  value       = aws_instance.mariadb.private_ip
}

# Ansible Inventory File
resource "local_file" "ansible_inventory" {
  filename = "../ansible/inventory"

  content = templatefile("${path.module}/inventory.tmpl", {
    nginx_ip   = aws_instance.nginx_ec2.private_ip
    nginx_public_ip   = aws_instance.nginx_ec2.public_ip
    python_ip  = aws_instance.python_api.private_ip
    mariadb_ip = aws_instance.mariadb.private_ip

    nginx_user   = var.ansibleUserByOS[aws_instance.nginx_ec2.tags.os]
    python_user  = var.ansibleUserByOS[aws_instance.python_api.tags.os]
    mariadb_user = var.ansibleUserByOS[aws_instance.mariadb.tags.os]    

    clientkey  = aws_key_pair.client_keypair.key_name
    
    depends_on = [
    aws_instance.nginx_ec2,
    aws_instance.python_api,
    aws_instance.mariadb
  ]
  })
}

# Deployment script for Ansible
resource "local_file" "ansible_deployment" {
  filename = "../${var.deployName}"

  content = templatefile("${path.module}/deploy.tmpl", {
    ansible_ip       = aws_instance.ansible_ec2.public_ip
    ansible_user     = var.ansibleUserByOS[aws_instance.ansible_ec2.tags.os]
    clientkey        = "${aws_key_pair.client_keypair.key_name}.pem"
  })
}

# Run deployment script
resource "null_resource" "run_deploy_script" {
  depends_on = [
    aws_instance.nginx_ec2,
    aws_instance.python_api,
    aws_instance.mariadb,
    local_file.ansible_deployment
  ]

  provisioner "local-exec" {
    working_dir = "${path.module}/.."
    command = "bash ./deployment_script.sh"
  }
}

# GitHub access keys
output "github_access_key_id" {
  value = aws_iam_access_key.GitHubActions.id
}

output "github_secret_access_key" {
  value     = aws_iam_access_key.GitHubActions.secret    
  sensitive = true  
}
# Ansible EC2 instance ID
output "ansible_ec2_id" {
  value = aws_instance.ansible_ec2.id
}

# S3 bucket ID
output "s3_bucket__id" {
  value = aws_s3_bucket.ansible_deploy.id
}
