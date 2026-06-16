provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
    }
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.8.26"
  namespace        = "argocd"
  create_namespace = true
  take_ownership   = true

  values = [templatefile("${path.module}/argocd-values.yaml.tftpl", {
    account_id = data.aws_caller_identity.current.account_id
    region     = var.region
  })]

  depends_on = [module.eks]
}
