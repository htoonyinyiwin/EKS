env          = "prod"
project_name = "eks"
region       = "ap-northeast-1"

# EKS
eks_version    = "1.35"
instance_types = ["t3a.medium"] # ["m5.large"] for real production sizing
desired_size   = 3
min_size       = 2
max_size       = 4
disk_size      = 20

admin_iam_arns = [
  # "arn:aws:iam::<PROD_ACCOUNT_ID>:user/github-eksprod",
  # "arn:aws:iam::<PROD_ACCOUNT_ID>:role/github-oidc-eks-ecr-role-prod",
]

# RDS
db_instance_class = "db.t3.micro" # db.t3.small for real production sizing
db_engine_version = "17"
db_name           = "appdb"
db_username          = "app_user"
enable_rds_replica   = false # recommend true for production HA (adds a read replica)

# ElastiCache Redis
redis_node_type            = "cache.t3.micro" # cache.t3.small for real production sizing
redis_parameter_group_name = "default.redis7"
redis_engine_version       = "7.0"
redis_apply_immediately    = true
redis_num_cache_nodes      = 1
redis_port                 = 6379
redis_single_node_cluster    = 1
enable_redis_replication     = false # recommend true for production HA (adds replication group with 2 nodes)
