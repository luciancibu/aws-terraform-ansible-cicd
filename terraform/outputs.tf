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
