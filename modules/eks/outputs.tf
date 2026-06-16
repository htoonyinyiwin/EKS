output "cluster_name" {
  value       = aws_eks_cluster.cluster.name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.cluster.endpoint
  description = "EKS API server endpoint"
}

output "cluster_ca_certificate" {
  value       = aws_eks_cluster.cluster.certificate_authority[0].data
  description = "Base64-encoded cluster CA certificate"
  sensitive   = true
}

output "node_role_arn" {
  value       = aws_iam_role.eks_nodes.arn
  description = "Worker node IAM role ARN"
}

output "cluster_oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.eks.arn
  description = "EKS OIDC provider ARN — used for IRSA trust policies"
}

output "cluster_oidc_provider" {
  value       = replace(aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
  description = "EKS OIDC provider URL without https:// — used in IRSA trust conditions"
}
