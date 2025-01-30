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

# Custom permissions
data "aws_iam_policy_document" "custom_permissions" {
  for_each = var.permissions

  statement {
    effect    = each.value.effect
    actions   = each.value.actions
    resources = each.value.resources
  }
}

resource "aws_iam_role_policy" "generated_policies" {
  for_each = data.aws_iam_policy_document.custom_permissions

  name   = "policy_${each.key}"
  policy = each.value.json
  role   = aws_iam_role.role_github_actions.id
}