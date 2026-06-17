provider "aws" {
  region = var.region
}

# used for standard k8s resources (Deployments, Services, etc.) — validates against live API
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
  }
}

# used for CRD-backed resources (ESO ClusterSecretStore, ExternalSecret) — no schema validation at plan time
provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  load_config_file       = false
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
  }
}

data "aws_caller_identity" "current" {}

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

data "aws_route_table" "private" {
  vpc_id = data.aws_vpc.this.id
  filter {
    name   = "tag:Name"
    values = ["private-${var.env}"]
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
