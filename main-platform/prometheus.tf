resource "helm_release" "prometheus" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "61.9.0"
  namespace        = "monitoring"
  create_namespace = true

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
