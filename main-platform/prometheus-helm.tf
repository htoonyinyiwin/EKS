resource "helm_release" "prometheus" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "61.9.0"
  namespace        = "monitoring"
  create_namespace = true
  timeout          = 600
  wait             = false # pods depend on grafana-cloud-secret which ESO syncs async; don't block tf apply

  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          retention = "7d"
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "gp3"
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = { storage = "10Gi" }
                }
              }
            }
          }
          remoteWrite = [
            {
              url = "https://prometheus-prod-37-prod-ap-southeast-1.grafana.net/api/prom/push"
              basicAuth = {
                username = { name = "grafana-cloud-secret", key = "username" }
                password = { name = "grafana-cloud-secret", key = "password" }
              }
            }
          ]

          # scrape ServiceMonitors and PrometheusRules from all namespaces
          serviceMonitorSelectorNilUsesHelmValues = false
          serviceMonitorNamespaceSelector         = {}
          serviceMonitorSelector                  = {}
          ruleSelectorNilUsesHelmValues           = false
          ruleNamespaceSelector                   = {}
          ruleSelector                            = {}
        }
      }

      grafana = {
        adminPassword = "admin"
        ingress = {
          enabled = true
          annotations = {
            "kubernetes.io/ingress.class"           = "alb"
            "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
            "alb.ingress.kubernetes.io/target-type" = "ip"
          }
          hosts = []
        }
        persistence = {
          enabled          = true
          storageClassName = "gp3"
          size             = "5Gi"
        }
      }

      alertmanager = {
        alertmanagerSpec = {
          storage = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "gp3"
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = { storage = "2Gi" }
                }
              }
            }
          }
          # watch AlertmanagerConfig resources with this label across all namespaces
          alertmanagerConfigSelector = {
            matchLabels = { alertmanagerConfig = "true" }
          }
          alertmanagerConfigNamespaceSelector = {} # empty = all namespaces
        }
      }
    })
  ]

  depends_on = [
    module.eks,
    helm_release.alb_controller,
    aws_eks_addon.ebs_csi,
    kubernetes_storage_class.gp3,
  ]
}
