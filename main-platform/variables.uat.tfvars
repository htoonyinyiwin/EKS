env          = "uat"
project_name = "eks"
region       = "ap-northeast-1"

# EKS
eks_version    = "1.35"
instance_types = ["t3a.medium"]
desired_size   = 1
min_size       = 1
max_size       = 2
disk_size      = 20

admin_iam_arns = [
  "arn:aws:iam::051602877369:user/github-eksuat",
  "arn:aws:iam::051602877369:role/github-oidc-eks-ecr-role-uat",
]
