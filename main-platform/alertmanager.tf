resource "aws_secretsmanager_secret" "alertmanager_slack" {
  name                    = "alertmanager/slack-webhook"
  recovery_window_in_days = 0

  tags = {
    Name        = "alertmanager-slack-webhook"
    Environment = var.env
  }
}

# After tf apply, populate with:
# aws secretsmanager put-secret-value \
#   --secret-id alertmanager/slack-webhook \
#   --secret-string '{"url":"https://hooks.slack.com/services/..."}' \
#   --region ap-northeast-1 \
#   --profile github-eksuat

resource "kubectl_manifest" "external_secret_alertmanager_slack" {
  yaml_body = yamlencode({
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "alertmanager-slack-secret"
      namespace = "monitoring"
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "aws-secrets-manager"
        kind = "ClusterSecretStore"
      }
      target = {
        name = "alertmanager-slack-secret"
      }
      data = [
        {
          secretKey = "url"
          remoteRef = { key = "alertmanager/slack-webhook", property = "url" }
        }
      ]
    }
  })

  depends_on = [kubectl_manifest.cluster_secret_store]
}

resource "kubectl_manifest" "alertmanager_config_slack" {
  yaml_body = yamlencode({
    apiVersion = "monitoring.coreos.com/v1alpha1"
    kind       = "AlertmanagerConfig"
    metadata = {
      name      = "slack-alerts"
      namespace = "monitoring"
      labels    = { alertmanagerConfig = "true" }
    }
    spec = {
      route = {
        groupBy        = ["alertname", "namespace"]
        groupWait      = "30s"
        groupInterval  = "5m"
        repeatInterval = "12h"
        receiver       = "slack"
      }
      receivers = [
        {
          name = "slack"
          slackConfigs = [
            {
              apiURL = {
                name = "alertmanager-slack-secret"
                key  = "url"
              }
              channel      = "#alerts"
              sendResolved = true
              title        = "[{{ .Status | toUpper }}] {{ .CommonLabels.alertname }}"
              text         = "{{ range .Alerts }}*Alert:* {{ .Annotations.summary }}\n*Severity:* {{ .Labels.severity }}\n*Namespace:* {{ .Labels.namespace }}\n{{ end }}"
            }
          ]
        }
      ]
    }
  })

  depends_on = [kubectl_manifest.external_secret_alertmanager_slack]
}

resource "kubectl_manifest" "prometheus_rule_pod_alerts" {
  yaml_body = yamlencode({
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "pod-alerts"
      namespace = "monitoring"
      labels    = { release = "kube-prometheus-stack" }
    }
    spec = {
      groups = [
        {
          name = "pod.rules"
          rules = [
            {
              alert  = "PodCrashLooping"
              expr   = "rate(kube_pod_container_status_restarts_total[5m]) * 60 > 0"
              for    = "5m"
              labels = { severity = "critical" }
              annotations = {
                summary     = "Pod {{ $labels.pod }} is crash looping"
                description = "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} is restarting frequently"
              }
            },
            {
              alert  = "PodNotReady"
              expr   = "kube_pod_status_ready{condition=\"false\"} == 1"
              for    = "5m"
              labels = { severity = "warning" }
              annotations = {
                summary     = "Pod {{ $labels.pod }} is not ready"
                description = "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} has been not ready for more than 5 minutes"
              }
            }
          ]
        }
      ]
    }
  })
}
