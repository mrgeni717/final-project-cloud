terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "final-project-cloud-tfstate-975769101514"
    key            = "network/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "final-project-cloud-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}
