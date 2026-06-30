provider "aws" {

  region = var.aws_region

  default_tags {

    tags = {

      Project = "URL-Shortener"

      Environment = "Dev"

      ManagedBy = "Terraform"

    }

  }

}
