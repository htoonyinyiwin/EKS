terraform {
  required_version = ">= 1.15.0"

  backend "s3" {
    # check in tfbackend.hcl files
  }

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.47.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
  }
}