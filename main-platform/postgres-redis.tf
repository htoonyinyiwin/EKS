locals {
  # ECR pull-through cache prefix for Docker Hub images — ECR fetches and caches on first pull
  ecr_docker_hub = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/docker-hub"
}

resource "helm_release" "postgresql" {
  name             = "postgresql"
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "postgresql"
  version          = "17.1.0"
  namespace        = "database"
  create_namespace = true

  values = [
    yamlencode({
      image = {
        registry   = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
        repository = "docker-hub/bitnami/postgresql"
        tag        = "17.6.0-debian-12-r4"
      }
      auth = {
        database       = "appdb"
        username       = "app_user"
        existingSecret = "app-db-secret"
        secretKeys = {
          adminPasswordKey = "password"
          userPasswordKey  = "password"
        }
      }
      primary = {
        persistence = {
          enabled = true
          size    = "8Gi"
        }
      }
    })
  ]

  depends_on = [module.eks, kubectl_manifest.external_secret_app_db]
}

resource "helm_release" "redis" {
  name             = "redis"
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart            = "redis"
  version          = "23.1.1"
  namespace        = "database"
  create_namespace = true

  values = [
    yamlencode({
      image = {
        registry   = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
        repository = "docker-hub/bitnami/redis"
        tag        = "8.2.1-debian-12-r0"
      }
      auth = {
        enabled = false
      }
      master = {
        persistence = {
          enabled = true
          size    = "4Gi"
        }
      }
      replica = {
        replicaCount = 0
      }
    })
  ]

  depends_on = [module.eks]
}
