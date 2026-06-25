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

admin_iam_arns = [
  "arn:aws:iam::298225145086:user/github-eks",
  "arn:aws:iam::298225145086:role/github-oidc-eks-ecr-role-dev",
]

# RDS
db_instance_class = "db.t3.micro"
db_engine_version = "17"
db_name           = "appdb"
db_username          = "app_user"
enable_rds_replica   = false

# ElastiCache Redis
redis_node_type            = "cache.t3.micro"
redis_parameter_group_name = "default.redis7"
redis_engine_version       = "7.0"
redis_apply_immediately    = true
redis_num_cache_nodes      = 1
redis_port                 = 6379
redis_single_node_cluster    = 1
enable_redis_replication     = false
