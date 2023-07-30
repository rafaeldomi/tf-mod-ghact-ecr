output "role_arn" {
  value = module.auth-ecr-github.role_arn
}

output "ecr_endpoint" {
  value = aws_ecr_repository.ecr_repo.repository_url
}