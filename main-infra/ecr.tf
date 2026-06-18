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
