resource "aws_secretsmanager_secret" "grafana_cloud" {
  name                    = "grafana-cloud/remote-write"
  recovery_window_in_days = 0

  tags = {
    Name        = "grafana-cloud-remote-write"
    Environment = var.env
  }
}

# After tf apply, populate with:
# aws secretsmanager put-secret-value \
#   --secret-id grafana-cloud/remote-write \
#   --secret-string '{"username":"3320216","password":"YOUR_API_TOKEN"}' \
#   --region ap-northeast-1 \
#   --profile github-eksuat

resource "kubectl_manifest" "external_secret_grafana_cloud" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "grafana-cloud-secret"
      namespace = "monitoring"
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "aws-secrets-manager"
        kind = "ClusterSecretStore"
      }
      target = {
        name = "grafana-cloud-secret"
      }
      data = [
        {
          secretKey = "username"
          remoteRef = { key = "grafana-cloud/remote-write", property = "username" }
        },
        {
          secretKey = "password"
          remoteRef = { key = "grafana-cloud/remote-write", property = "password" }
        }
      ]
    }
  })

  depends_on = [
    kubectl_manifest.cluster_secret_store,
    helm_release.prometheus,
  ]
}
