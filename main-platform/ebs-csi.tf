# IRSA role for EBS CSI driver — allows the driver to call EC2 APIs to create/attach/delete EBS volumes
resource "aws_iam_role" "ebs_csi" {
  name = "eks-ebs-csi-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = module.eks.cluster_oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${module.eks.cluster_oidc_provider}:aud" = "sts.amazonaws.com"
          "${module.eks.cluster_oidc_provider}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }]
  })

  tags = {
    Name        = "eks-ebs-csi-role-${var.env}"
    Environment = var.env
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# EBS CSI driver managed addon — provisions EBS volumes for PersistentVolumeClaims
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi.arn

  depends_on = [aws_iam_role_policy_attachment.ebs_csi]
}

# gp3 StorageClass — default storage for PVCs (PostgreSQL, Redis)
# gp3 is newer and cheaper than gp2, provisioned by the EBS CSI driver
resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type = "gp3"
  }

  depends_on = [aws_eks_addon.ebs_csi]
}
