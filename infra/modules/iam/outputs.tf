output "ec2_instance_profile_name" {
  value       = aws_iam_instance_profile.ec2_ssm_instance_profile.name
}

output "github_actions_access_key_id" {
  value = aws_iam_access_key.github_actions.id
}

output "github_actions_secret_access_key" {
  value     = aws_iam_access_key.github_actions.secret
  sensitive = true
}
