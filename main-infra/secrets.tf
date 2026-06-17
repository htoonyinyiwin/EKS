# generates a cryptographically secure random password
resource "random_password" "app_db" {
  length           = 32
  special          = true
  override_special = "!#-_=+"
}

# creates the secret entry in Secrets Manager (empty shell, no value yet)
resource "aws_secretsmanager_secret" "app_db" {
  name                    = "${var.env}/app/db-password"
  description             = "App DB credentials for ${var.env}"
  recovery_window_in_days = 0

  tags = {
    Name        = "${var.env}-app-db-password"
    Environment = var.env
  }
}

# stores the actual secret value (username + generated password)
resource "aws_secretsmanager_secret_version" "app_db" {
  secret_id = aws_secretsmanager_secret.app_db.id
  secret_string = jsonencode({
    username = "app_user"
    password = random_password.app_db.result
  })
}

# Docker Hub credentials used by ECR pull-through cache to fetch Bitnami images
resource "aws_secretsmanager_secret" "docker_hub" {
  name                    = "ecr-pullthroughcache/docker-hub"
  description             = "Docker Hub credentials for ECR pull-through cache"
  recovery_window_in_days = 0

  tags = {
    Name        = "ecr-pullthroughcache-docker-hub"
    Environment = var.env
  }
}

# placeholder values — update the real token via console or CLI, Terraform will not overwrite it
resource "aws_secretsmanager_secret_version" "docker_hub" {
  secret_id = aws_secretsmanager_secret.docker_hub.id
  secret_string = jsonencode({
    username    = "brianaung"
    accessToken = "placeholder"
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}
