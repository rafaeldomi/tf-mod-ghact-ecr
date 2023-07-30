terraform {
  required_providers {
    # the last version in the date of creation of this project
    aws = "~> 5.9"

    github = {
      source  = "integrations/github"
      version = "~> 5.32"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

provider "github" {
    # Create a token specific for this
    token = var.github_token
}