provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 1.15.0"

  backend "s3" {
    # check in .hcl files
  }

  # backend "local" {
  #   path = "state2/terraform-uat.tfstate"
  # }

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.47.0"
    }
  }
}
