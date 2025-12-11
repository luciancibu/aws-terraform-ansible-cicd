# Documentation for aws_iam_user resource:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user

# IAM user dor GitHub Actions
resource "aws_iam_user" "GitHubActions" {
  name = "${var.projectName}-GitHubActionsUser"

  tags = {
    Name    = "${var.projectName}-user-GitHubActions"
    Project = var.projectName
  }
}

data "aws_iam_policy_document" "GitHubActions_ro" {

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "ec2:DescribeInstanceStatus"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:SendCommand",
      "ssm:GetCommandInvocation",
      "ssm:ListCommands",
      "ssm:ListCommandInvocations",
      "ssm:DescribeInstanceInformation"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.ansible_deploy.arn,
      "${aws_s3_bucket.ansible_deploy.arn}/*"
    ]
  }
}


resource "aws_iam_user_policy" "GitHubActions_ro" {
  name   = "${var.projectName}-test"
  user   = aws_iam_user.GitHubActions.name
  policy = data.aws_iam_policy_document.GitHubActions_ro.json
}

resource "aws_iam_access_key" "GitHubActions" {
  user = aws_iam_user.GitHubActions.name
}

# IAM Role and Instance Profile for EC2 instances to be managed by SSM
resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.projectName}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_role_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "s3_read" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "ec2_ssm_instance_profile" {
  name = "${var.projectName}-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}
