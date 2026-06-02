# identity provider for github actions

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.thumbprint_list
}

resource "aws_iam_role" "github_oidc_role" {
  name = "github-oidc-eks-ecr-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:brianaung95/EKS:*"
        },
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = {
    Name        = "GitHub OIDC Role - ${var.environment}"
    Environment = var.environment
  }
}

resource "aws_iam_policy" "github_ecr_eks_policy" {
  name = "GitHub_ECR_EKS_Access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_policy_attach" {
  role       = aws_iam_role.github_oidc_role.name
  policy_arn = aws_iam_policy.github_ecr_eks_policy.arn
}

# Command to get thumbprint via terminal

# openssl s_client -connect token.actions.githubusercontent.com:443 \
#   -servername token.actions.githubusercontent.com \
#   </dev/null 2>/dev/null | openssl x509 -fingerprint -noout \
#   | sed 's/SHA1 Fingerprint=//g' | sed 's/://g' | tr '[:upper:]' '[:lower:]'
