env          = "dev"
project_name = "eks"
region       = "ap-northeast-1"

# EKS
eks_version    = "1.35"
instance_types = ["t3a.medium"]
desired_size   = 1
min_size       = 1
max_size       = 2
disk_size      = 20
