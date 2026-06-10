provider "aws" {
  region = var.region
}

data "aws_vpc" "this" {
  tags = {
    Name = "${var.project_name}-infra-vpc-${var.env}"
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "tag:Name"
    values = ["private-*-${var.env}"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "tag:Name"
    values = ["public-*-${var.env}"]
  }
}

module "eks" {
  source = "../modules/eks"

  env          = var.env
  project_name = var.project_name

  vpc_id             = data.aws_vpc.this.id
  private_subnet_ids = data.aws_subnets.private.ids
  public_subnet_ids  = data.aws_subnets.public.ids

  eks_version    = var.eks_version
  instance_types = var.instance_types
  desired_size   = var.desired_size
  min_size       = var.min_size
  max_size       = var.max_size
  disk_size      = var.disk_size
  admin_iam_arns = var.admin_iam_arns
}
