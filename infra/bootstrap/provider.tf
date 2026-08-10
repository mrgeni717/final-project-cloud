terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Intentionally NO backend block here — this config creates the
  # remote state backend itself, so its own state stays local.
  # Only run this once per project.
}

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}
