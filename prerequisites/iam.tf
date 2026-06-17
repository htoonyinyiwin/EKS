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
          "token.actions.githubusercontent.com:sub" = "repo:htoonyinyiwin/EKS:*"
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

resource "aws_iam_policy" "github_terraform_policy" {
  name = "GitHub_Terraform_EKS_Infra"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # S3 — tfstate read/write
      {
        Sid    = "TfState"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketVersioning",
          "s3:CreateBucket",
          "s3:PutBucketVersioning",
          "s3:PutEncryptionConfiguration"
        ]
        Resource = [
          "arn:aws:s3:::proj-tfstate-${var.environment}",
          "arn:aws:s3:::proj-tfstate-${var.environment}/*"
        ]
      },
      # EC2 — VPC, subnets, IGW, route tables, security groups
      {
        Sid    = "VPC"
        Effect = "Allow"
        Action = [
          "ec2:CreateVpc", "ec2:DeleteVpc", "ec2:DescribeVpcs", "ec2:ModifyVpcAttribute",
          "ec2:CreateSubnet", "ec2:DeleteSubnet", "ec2:DescribeSubnets", "ec2:ModifySubnetAttribute",
          "ec2:CreateInternetGateway", "ec2:DeleteInternetGateway", "ec2:AttachInternetGateway", "ec2:DetachInternetGateway", "ec2:DescribeInternetGateways",
          "ec2:CreateRouteTable", "ec2:DeleteRouteTable", "ec2:DescribeRouteTables",
          "ec2:CreateRoute", "ec2:DeleteRoute",
          "ec2:AssociateRouteTable", "ec2:DisassociateRouteTable",
          "ec2:CreateSecurityGroup", "ec2:DeleteSecurityGroup", "ec2:DescribeSecurityGroups",
          "ec2:AuthorizeSecurityGroupIngress", "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress", "ec2:RevokeSecurityGroupEgress",
          "ec2:CreateTags", "ec2:DeleteTags", "ec2:DescribeTags",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplates", "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeVpcAttribute",
          "ec2:CreateVpcEndpoint", "ec2:DeleteVpcEndpoints", "ec2:DescribeVpcEndpoints", "ec2:ModifyVpcEndpoint",
          "ec2:DescribeVpcEndpointServices", "ec2:DescribeSecurityGroupRules",
          "ec2:DescribePrefixLists", "ec2:DescribeAccountAttributes"
        ]
        Resource = "*"
      },
      # EKS — cluster + node group lifecycle
      {
        Sid    = "EKS"
        Effect = "Allow"
        Action = [
          "eks:CreateCluster", "eks:DeleteCluster", "eks:DescribeCluster", "eks:ListClusters",
          "eks:UpdateClusterConfig", "eks:UpdateClusterVersion",
          "eks:CreateNodegroup", "eks:DeleteNodegroup", "eks:DescribeNodegroup", "eks:ListNodegroups", "eks:UpdateNodegroupConfig", "eks:UpdateNodegroupVersion",
          "eks:TagResource", "eks:UntagResource", "eks:ListTagsForResource",
          "eks:CreateAccessEntry", "eks:DeleteAccessEntry", "eks:DescribeAccessEntry", "eks:ListAccessEntries",
          "eks:AssociateAccessPolicy", "eks:DisassociateAccessPolicy", "eks:ListAssociatedAccessPolicies",
          "eks:CreateAddon", "eks:DeleteAddon", "eks:DescribeAddon", "eks:ListAddons", "eks:UpdateAddon", "eks:DescribeAddonVersions"
        ]
        Resource = "*"
      },
      # IAM — roles and policies for EKS cluster and nodes
      {
        Sid    = "IAM"
        Effect = "Allow"
        Action = [
          "iam:CreateRole", "iam:DeleteRole", "iam:GetRole", "iam:PassRole",
          "iam:CreateServiceLinkedRole",
          "iam:AttachRolePolicy", "iam:DetachRolePolicy", "iam:ListAttachedRolePolicies",
          "iam:CreatePolicy", "iam:DeletePolicy", "iam:GetPolicy", "iam:GetPolicyVersion", "iam:ListPolicyVersions",
          "iam:CreateOpenIDConnectProvider", "iam:DeleteOpenIDConnectProvider", "iam:GetOpenIDConnectProvider", "iam:ListOpenIDConnectProviders", "iam:TagOpenIDConnectProvider", "iam:UntagOpenIDConnectProvider",
          "iam:CreateInstanceProfile", "iam:DeleteInstanceProfile", "iam:GetInstanceProfile",
          "iam:AddRoleToInstanceProfile", "iam:RemoveRoleFromInstanceProfile",
          "iam:TagRole", "iam:UntagRole", "iam:ListRoleTags",
          "iam:ListRolePolicies", "iam:ListInstanceProfilesForRole",
          "iam:UpdateAssumeRolePolicy",
          "iam:PutRolePolicy", "iam:DeleteRolePolicy", "iam:GetRolePolicy"
        ]
        Resource = "*"
      },
      # ECR — repository management + image push
      {
        Sid    = "ECR"
        Effect = "Allow"
        Action = [
          "ecr:CreateRepository", "ecr:DeleteRepository", "ecr:DescribeRepositories",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability", "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer", "ecr:InitiateLayerUpload",
          "ecr:PutImage", "ecr:UploadLayerPart",
          "ecr:PutLifecyclePolicy", "ecr:GetLifecyclePolicy",
          "ecr:TagResource", "ecr:UntagResource", "ecr:ListTagsForResource",
          "ecr-public:GetAuthorizationToken", "sts:GetServiceBearerToken",
          "ecr:CreatePullThroughCacheRule", "ecr:DeletePullThroughCacheRule",
          "ecr:DescribePullThroughCacheRules", "ecr:BatchImportUpstreamImage"
        ]
        Resource = "*"
      },
      # Budgets — cost alerts
      {
        Sid    = "Budgets"
        Effect = "Allow"
        Action = [
          "budgets:CreateBudget", "budgets:ModifyBudget", "budgets:DeleteBudget",
          "budgets:ViewBudget", "budgets:DescribeBudgetActionsForBudget",
          "budgets:ListTagsForResource", "budgets:TagResource", "budgets:UntagResource"
        ]
        Resource = "*"
      },
      # CloudWatch Logs — EKS control plane logging
      {
        Sid    = "Logs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup", "logs:DeleteLogGroup", "logs:DescribeLogGroups",
          "logs:PutRetentionPolicy", "logs:TagResource", "logs:ListTagsForResource"
        ]
        Resource = "*"
      },
      # RDS — PostgreSQL instance lifecycle
      {
        Sid    = "RDS"
        Effect = "Allow"
        Action = [
          "rds:CreateDBInstance", "rds:DeleteDBInstance", "rds:DescribeDBInstances", "rds:ModifyDBInstance",
          "rds:CreateDBSubnetGroup", "rds:DeleteDBSubnetGroup", "rds:DescribeDBSubnetGroups", "rds:ModifyDBSubnetGroup",
          "rds:CreateDBParameterGroup", "rds:DeleteDBParameterGroup", "rds:DescribeDBParameterGroups", "rds:ModifyDBParameterGroup",
          "rds:DescribeDBEngineVersions",
          "rds:AddTagsToResource", "rds:ListTagsForResource", "rds:RemoveTagsFromResource"
        ]
        Resource = "*"
      },
      # ElastiCache — Redis cluster lifecycle
      {
        Sid    = "ElastiCache"
        Effect = "Allow"
        Action = [
          "elasticache:CreateCacheCluster", "elasticache:DeleteCacheCluster", "elasticache:DescribeCacheClusters", "elasticache:ModifyCacheCluster",
          "elasticache:CreateCacheSubnetGroup", "elasticache:DeleteCacheSubnetGroup", "elasticache:DescribeCacheSubnetGroups", "elasticache:ModifyCacheSubnetGroup",
          "elasticache:CreateCacheParameterGroup", "elasticache:DeleteCacheParameterGroup", "elasticache:DescribeCacheParameterGroups",
          "elasticache:DescribeCacheEngineVersions",
          "elasticache:AddTagsToResource", "elasticache:ListTagsForResource", "elasticache:RemoveTagsFromResource"
        ]
        Resource = "*"
      },
      # Secrets Manager — app secrets
      {
        Sid    = "SecretsManager"
        Effect = "Allow"
        Action = [
          "secretsmanager:CreateSecret", "secretsmanager:DeleteSecret", "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue", "secretsmanager:PutSecretValue", "secretsmanager:UpdateSecret",
          "secretsmanager:TagResource", "secretsmanager:UntagResource", "secretsmanager:ListSecretVersionIds",
          "secretsmanager:GetResourcePolicy", "secretsmanager:RestoreSecret"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_policy_attach" {
  role       = aws_iam_role.github_oidc_role.name
  policy_arn = aws_iam_policy.github_terraform_policy.arn
}

# Command to get thumbprint via terminal

# openssl s_client -connect token.actions.githubusercontent.com:443 \
#   -servername token.actions.githubusercontent.com \
#   </dev/null 2>/dev/null | openssl x509 -fingerprint -noout \
#   | sed 's/SHA1 Fingerprint=//g' | sed 's/://g' | tr '[:upper:]' '[:lower:]'
