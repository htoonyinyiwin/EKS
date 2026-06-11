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
