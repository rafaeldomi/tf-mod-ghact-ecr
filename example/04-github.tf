resource "github_repository" "gh_repo" {
  name        = var.github_reponame
  description = "The example repo for ${var.github_reponame}"
  visibility  = "private"
}

resource "github_actions_variable" "var_ecr_registry" {
  repository    = var.github_reponame
  variable_name = "ECR_REGISTRY"
  value         = element(split("/", aws_ecr_repository.ecr_repo.repository_url), 0)
}

resource "github_actions_variable" "var_role_name" {
  repository    = var.github_reponame
  variable_name = "ROLE_NAME"
  value         = module.auth-ecr-github.role_arn
}

resource "github_actions_variable" "var_ecr_repo" {
  repository    = var.github_reponame
  variable_name = "ECR_REPO_NAME"
  value         = aws_ecr_repository.ecr_repo.name
}