module "auth-ecr-github" {
  source = "github.com/rafaeldomi/tf-mod-ghact-ecr?ref=v01/modules/auth-ecr-github"

  role_name = "github-actions-role"

  allow_repo = [
    "repo:${github_repository.gh_repo.full_name}:*"
  ]
}