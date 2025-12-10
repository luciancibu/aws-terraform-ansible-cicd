#Documentation for aws_iam_user resource:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user

resource "aws_iam_user" "GitHubActions" {
  name = "GitHubActionsUser"

  tags = {
    Name    = "${var.projectName}-user-GitHubActions"
    Project = var.projectName
  }
}

data "aws_iam_policy_document" "GitHubActions_ro" {
  statement {
    effect    = "Allow"
    actions = [
    "ec2:DescribeInstances",
    "ec2:DescribeTags",
    "ec2:DescribeInstanceStatus"
    ]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions = [
    "ssm:SendCommand",
    "ssm:GetCommandInvocation",
    "ssm:ListCommands",
    "ssm:ListCommandInvocations",
    "ssm:DescribeInstanceInformation"
    ]
    resources = ["*"]
  }  
}

resource "aws_iam_user_policy" "GitHubActions_ro" {
  name   = "test"
  user   = aws_iam_user.GitHubActions.name
  policy = data.aws_iam_policy_document.GitHubActions_ro.json
}

resource "aws_iam_access_key" "GitHubActions" {
  user = aws_iam_user.GitHubActions.name
}