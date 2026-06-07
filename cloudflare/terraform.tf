terraform {
  required_version = ">= 1.15.0"

  backend "s3" {
    # check in .hcl files
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.19.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
