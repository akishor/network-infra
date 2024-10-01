terraform {
  required_providers {
    aws = {
      version = ">= 5.0.0"
      source  = "hashicorp/aws"
    }

  }
  backend "s3" {
        bucket = "terraform-state-bucket-ashwani-93120665"
        key = "terraformstate.tf"
        region = "eu-central-1"
    }
}

provider "aws" {
  region = "eu-central-1"
}