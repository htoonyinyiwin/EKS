terraform {
  required_version = ">= 1.15.0"

  backend "s3" {
    # check in .hcl files
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.47.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    # hashicorp/kubernetes validates CRD schemas at plan time — fails on fresh clusters before CRDs exist
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
    # gavinbunney/kubectl skips schema validation — safe for kubectl_manifest on CRD-backed resources like ESO
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19"
    }
  }
}
