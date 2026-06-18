resource "kubectl_manifest" "booking_app" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "booking-app"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/htoonyinyiwin/EKS"
        targetRevision = "main"
        path           = "booking-app/k8s"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "booking-app"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = ["CreateNamespace=true"]
      }
    }
  })

  depends_on = [helm_release.argocd]
}
