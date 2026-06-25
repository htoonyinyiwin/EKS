provider "aws" {
  region = "ap-northeast-1"
}

data "aws_caller_identity" "current" {}

module "infra" {
  source       = "../modules/infra-modules"
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

  # ECR
  ecr_images_to_retain                        = var.ecr_images_to_retain
  count_ecr_replication_configuration         = var.count_ecr_replication_configuration
  count_ecr_registry_policy                   = var.count_ecr_registry_policy
  ecr_replication_destination_prod_account_id = var.ecr_replication_destination_prod_account_id
  ecr_replication_destination_dev_account_id  = var.ecr_replication_destination_dev_account_id
  ecr_source_account_id                       = var.ecr_source_account_id

  # Budget
  budget_alert_email = var.budget_alert_email
}
