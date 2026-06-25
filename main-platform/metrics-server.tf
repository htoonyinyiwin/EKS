resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.2"

  values = [
    yamlencode({
      args = ["--kubelet-insecure-tls"] # EKS nodes use self-signed certs; metrics-server must skip TLS verify
    })
  ]
}
