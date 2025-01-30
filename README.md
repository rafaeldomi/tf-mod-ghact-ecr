# Terraform Module: [GithubActions] Auth to AWS securely

Use this module to login securely to AWS using the action aws-actions/configure-aws-credentials@v4 in github Actions. This module implements the necessary resources in AWS to login using Assume Role. Using this configuration one do not need to share access keys, creating a more secure environment.

# What is created
The module creates the following resources:
* OIDC Provider for GitHub Actions consumption
* Role for being assumed
* Define permission policy based on "permissions" input

# How to use
Very simple, just call the module, like this:

```terraform
module "auth-ecr-github" {
  # Point to the module source in the github
  # Alwyas check for the latest version
  source = "github.com/rafaeldomi/tf-mod-ghact-ecr?ref=v3/modules/auth-ecr-github"

  role_name = "github-actions-role"

  # Here you define the repo that is allowed to be assumed. Format is described below
  allow_repo = [
    "repo:{org/owner}/{repo-name}:*"
  ]

  # Now define the permissions that you want for this role
  permissions = {
    s3_permissions = {
      effect = "Allow"
      resources = ["*"]
      actions = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ]
    }
    ecr_permissions = {
      effect = "Allow"
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
      ]
    }
    ecs_task_deploy = {
      effect = "Allow"
      resources = ["*"]
      actions = [
        "ecs:DescribeTaskDefinition"
      , "ecs:RegisterTaskDefinition"
      , "ecs:RunTask"
      , "ecs:DescribeTasks"
      , "iam:PassRole"
      , "ecs:DescribeServices"
      , "ecs:UpdateService"
      , "ecr:DescribeImages"
      ]
    }
  }
}

# This value will be used in the github action
output "role_arn" {
  value = module.auth-ecr-github.role_arn
}
```

The allow_repo is the URL of the repository that is allowed to assume the role. GitHub Actions send this information to AWS using the Subject part (:sub). Note that this is a list, so you can configure this role to N repositories, as necessary.

# Configuring the Github Action

Example on how to use in the GitHubActions:

```yaml
name: Pipeline

on:
  push:
    branches: [ master ]

permissions:
  id-token: write
  contents: write

jobs:
  build:
    name: Build Image
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        role-to-assume: { RoleARN }
        aws-region: { AWSRegion }

    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1
```

Replace the values of RoleARN and AWSRegion.

# Outputs

| Name | Description |
| - | - |
| role_arn | The ARN of the Role created |

# Breaking Changes
* Version v3
  - Previous module set some permissions by default. In this version we removed that, now user needs to define the permissions needed for the role.