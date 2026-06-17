# IAM role for EKS control plane

resource "aws_iam_role" "eks_cluster" {
  name = "${var.project_name}-eks-cluster-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })

  tags = {
    Name        = "${var.project_name}-eks-cluster-role-${var.env}"
    Environment = var.env
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS cluster

resource "aws_eks_cluster" "cluster" {
  name     = "${var.project_name}-eks-${var.env}"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.eks_version

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]

  tags = {
    Name        = "${var.project_name}-eks-${var.env}"
    Environment = var.env
  }
}

# IAM role for worker nodes

resource "aws_iam_role" "eks_nodes" {
  name = "${var.project_name}-eks-node-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project_name}-eks-node-role-${var.env}"
    Environment = var.env
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# allows SSM Session Manager to shell into nodes — no SSH key or bastion host required
resource "aws_iam_role_policy_attachment" "eks_ssm_policy" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# allows nodes to trigger ECR pull-through cache (fetch images from upstream registries like Docker Hub)
resource "aws_iam_role_policy" "eks_ecr_pull_through" {
  name = "${var.project_name}-ecr-pull-through-${var.env}"
  role = aws_iam_role.eks_nodes.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecr:BatchImportUpstreamImage",
        "ecr:CreateRepository",
      ]
      Resource = "*"
    }]
  })
}

# Cluster admin access entries — recreated on each apply/destroy cycle

resource "aws_eks_access_entry" "admins" {
  for_each = toset(var.admin_iam_arns)

  cluster_name  = aws_eks_cluster.cluster.name
  principal_arn = each.value
  type          = "STANDARD"

  tags = {
    Environment = var.env
  }
}

resource "aws_eks_access_policy_association" "admins" {
  for_each = toset(var.admin_iam_arns)

  cluster_name  = aws_eks_cluster.cluster.name
  principal_arn = each.value
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admins]
}

# OIDC provider — enables IRSA (IAM Roles for Service Accounts)

data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer

  tags = {
    Name        = "${var.project_name}-eks-oidc-${var.env}"
    Environment = var.env
  }
}

# Worker node group

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${var.project_name}-node-group-${var.env}"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.private_subnet_ids

  instance_types = var.instance_types
  disk_size      = var.disk_size

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  update_config {
    max_unavailable_percentage = 25
  }

  node_repair_config {
    enabled = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_policy,
    aws_iam_role_policy_attachment.eks_ssm_policy,
  ]

  tags = {
    Name        = "${var.project_name}-node-group-${var.env}"
    Environment = var.env
  }
}
