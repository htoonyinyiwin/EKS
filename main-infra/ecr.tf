locals {
  ecr_repositories = [
    aws_ecr_repository.aws_load_balancer_controller.name,
    aws_ecr_repository.argocd.name,
    aws_ecr_repository.dex.name,
    aws_ecr_repository.redis.name,
    aws_ecr_repository.external_secrets.name,
    aws_ecr_repository.booking_app.name,
  ]
}

resource "aws_ecr_lifecycle_policy" "repos" {
  for_each   = toset(local.ecr_repositories)
  repository = each.value

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last ${var.ecr_images_to_retain} images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.ecr_images_to_retain
      }
      action = { type = "expire" }
    }]
  })
}

resource "aws_ecr_replication_configuration" "main" {
  count = var.count_ecr_replication_configuration

  replication_configuration {
    rule {
      repository_filter {
        filter      = var.project_name
        filter_type = "PREFIX_MATCH"
      }

      destination {
        region      = "ap-northeast-1"
        registry_id = var.ecr_replication_destination_account_id
      }
    }
  }
}

resource "aws_ecr_registry_policy" "allow_replication_from_source" {
  count = var.count_ecr_registry_policy

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowReplicationFromSource"
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${var.ecr_source_account_id}:root"
      }
      Action = [
        "ecr:ReplicateImage",
        "ecr:CreateRepository"
      ]
      Resource = "arn:aws:ecr:ap-northeast-1:${data.aws_caller_identity.current.account_id}:repository/*"
    }]
  })
}

resource "aws_ecr_repository" "aws_load_balancer_controller" {
  name                 = "aws-load-balancer-controller"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "aws-load-balancer-controller"
    Environment = var.env
  }
}

resource "aws_ecr_repository" "argocd" {
  name                 = "argocd"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "argocd"
    Environment = var.env
  }
}

resource "aws_ecr_repository" "dex" {
  name                 = "dex"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "dex"
    Environment = var.env
  }
}

resource "aws_ecr_repository" "redis" {
  name                 = "redis"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "redis"
    Environment = var.env
  }
}

resource "aws_ecr_repository" "external_secrets" {
  name                 = "external-secrets"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "external-secrets"
    Environment = var.env
  }
}

resource "aws_ecr_repository" "booking_app" {
  name                 = "booking-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "booking-app"
    Environment = var.env
  }
}

# [Docker Hub] Allows ECR to authenticate to Docker Hub when caching images on first pull
# resource "aws_ecr_pull_through_cache_rule" "docker_hub" {
#   ecr_repository_prefix = "docker-hub"
#   upstream_registry_url = "registry-1.docker.io"
#   credential_arn        = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:ecr-pullthroughcache/docker-hub"
# }
