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
