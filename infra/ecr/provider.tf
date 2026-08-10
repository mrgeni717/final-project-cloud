terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "final-project-cloud-tfstate-064453092192"
    key            = "ecr/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "final-project-cloud-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}
