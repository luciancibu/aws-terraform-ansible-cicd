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

    nginx_user   = var.ansible_user_by_os[aws_instance.nginx_ec2.tags.os]
    python_user  = var.ansible_user_by_os[aws_instance.python_api.tags.os]
    mariadb_user = var.ansible_user_by_os[aws_instance.mariadb.tags.os]    

    clientkey  = aws_key_pair.client_keypair.key_name
  })
}

