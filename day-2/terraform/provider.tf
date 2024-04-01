terraform {
  required_version = ">=1.3.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.11"
    }
  }

  # backend "s3" {
  #   bucket = "threetier-terraform-state"
  #   key = "state/terraform.tfstate"
  #   region = "ap-northeast-1"
  # }
}

provider "aws" {
  region = var.region
}