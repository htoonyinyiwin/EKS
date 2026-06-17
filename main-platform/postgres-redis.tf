resource "helm_release" "postgresql" {
  name             = "postgresql"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "postgresql"
  version          = "15.5.38"
  namespace        = "database"
  create_namespace = true

  values = [
    yamlencode({
      image = {
        registry   = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
        repository = "bitnami-postgresql"
        tag        = "17.4.0-debian-12-r0"
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
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "redis"
  version          = "20.3.0"
  namespace        = "database"
  create_namespace = true

  values = [
    yamlencode({
      image = {
        registry   = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
        repository = "bitnami-redis"
        tag        = "7.4.2-debian-12-r0"
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
