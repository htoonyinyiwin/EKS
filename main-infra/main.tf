provider "aws" {
  region = "ap-northeast-1"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "infra" {
  source       = "../modules/vpc"
  env          = var.env
  project_name = var.project_name

  # VPC
  azs             = var.azs
  vpc_cidr_block  = var.vpc_cidr_block
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  private_subnet_tags = var.private_subnet_tags
  public_subnet_tags  = var.public_subnet_tags
  count_eip           = var.count_eip

  public_internet_cidr_blocks = var.public_internet_cidr_blocks
}