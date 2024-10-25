resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"]
}

# The role that going to be used int he github actions to auth to push to ECR
resource "aws_iam_role" "role_github_actions" {
  name = var.role_name
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role_policy.json
}

# AssumeRole Policy
data "aws_iam_policy_document" "github_actions_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    condition {
      test = "StringEquals"
      values = [
        "sts.amazonaws.com"
      ]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = var.allow_repo
    }

    principals {
      type = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }
  }
}

# https://github.com/aws-actions/amazon-ecr-login
data "aws_iam_policy_document" "auth_ecr" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
        "ecr:GetAuthorizationToken"
      , "ecr:BatchGetImage"
      , "ecr:BatchCheckLayerAvailability"
      , "ecr:CompleteLayerUpload"
      , "ecr:GetDownloadUrlForLayer"
      , "ecr:InitiateLayerUpload"
      , "ecr:PutImage"
      , "ecr:UploadLayerPart"
      # For the task depoy
      , "ecs:DescribeTaskDefinition"
      , "ecs:RegisterTaskDefinition"
      , "ecs:RunTask"
      , "ecs:DescribeTasks"
      , "iam:PassRole"
      , "ecs:DescribeServices"
      , "ecs:UpdateService"
      , "ecr:DescribeImages"
      # For the task pipeline
      , "ssm:GetParameter"
      , "secretsmanager:GetSecretValue"
    ]
  }
}

/* ecs service scheduler role */
resource "aws_iam_role_policy" "role_auth_ecr" {
  name   = "ecr_auth_ecr"
  policy = data.aws_iam_policy_document.auth_ecr.json
  role   = aws_iam_role.role_github_actions.id
}