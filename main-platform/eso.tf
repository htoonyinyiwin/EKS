resource "aws_iam_policy" "eso" {
  name = "eks-eso-secretsmanager-policy-${var.env}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "SecretsManager"
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
      ]
      Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:*"
    }]
  })
}

resource "aws_iam_role" "eso" {
  name = "eks-eso-role-${var.env}"

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
          "${module.eks.cluster_oidc_provider}:sub" = "system:serviceaccount:external-secrets:external-secrets"
        }
      }
    }]
  })

  tags = {
    Name        = "eks-eso-role-${var.env}"
    Environment = var.env
  }
}

resource "aws_iam_role_policy_attachment" "eso" {
  role       = aws_iam_role.eso.name
  policy_arn = aws_iam_policy.eso.arn
}

resource "helm_release" "eso" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = "0.10.7"
  namespace        = "external-secrets"
  create_namespace = true

  values = [
    yamlencode({
      image = {
        repository = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/external-secrets"
        tag        = "v0.10.7"
      }
      webhook = {
        image = {
          repository = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/external-secrets"
          tag        = "v0.10.7"
        }
      }
      certController = {
        image = {
          repository = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com/external-secrets"
          tag        = "v0.10.7"
        }
      }
      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.eso.arn
        }
      }
    })
  ]

  depends_on = [
    module.eks,
    aws_iam_role_policy_attachment.eso,
  ]
}
