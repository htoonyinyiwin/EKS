# tells ESO which AWS region + IAM role to use when fetching secrets
resource "kubectl_manifest" "cluster_secret_store" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "aws-secrets-manager"
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.region
          auth = {
            jwt = {
              serviceAccountRef = {
                name      = "external-secrets"
                namespace = "external-secrets"
              }
            }
          }
        }
      }
    }
  })

  depends_on = [helm_release.eso]
}

# maps the Secrets Manager secret into a native Kubernetes secret
resource "kubectl_manifest" "external_secret_app_db" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "app-db-secret"
      namespace = "default"
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "aws-secrets-manager"
        kind = "ClusterSecretStore"
      }
      target = {
        name = "app-db-secret"
      }
      data = [
        {
          secretKey = "password"
          remoteRef = {
            key      = "${var.env}/app/db-password"
            property = "password"
          }
        },
        {
          secretKey = "username"
          remoteRef = {
            key      = "${var.env}/app/db-password"
            property = "username"
          }
        }
      ]
    }
  })

  depends_on = [kubectl_manifest.cluster_secret_store]
}
