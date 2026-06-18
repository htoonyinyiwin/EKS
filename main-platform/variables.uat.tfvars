env          = "uat"
project_name = "eks"
region       = "ap-northeast-1"

# EKS
eks_version    = "1.35"
instance_types = ["t3a.medium"]
desired_size   = 2
min_size       = 2
max_size       = 2
disk_size      = 20

admin_iam_arns = [
  "arn:aws:iam::051602877369:user/github-eksuat",
  "arn:aws:iam::051602877369:role/github-oidc-eks-ecr-role-uat",
]

# RDS
db_instance_class = "db.t3.micro"
db_engine_version = "17"
db_name           = "appdb"
db_username       = "app_user"

# ElastiCache Redis
redis_node_type                  = "cache.t3.micro"
redis_parameter_group_name       = "default.redis7"
redis_engine_version             = "7.0"
redis_apply_immediately          = true
redis_num_cache_nodes            = 1
redis_port                       = 6379
redis_single_node_cluster        = 1
redis_replication_group          = 0
redis_engine                     = "redis"
multi_az_enabled                 = false
automatic_failover_enabled       = false
num_node_groups                  = 1
replicas_per_node_group          = 0
num_cache_clusters               = 1
redis_at_rest_encryption_enabled = false
redis_transit_encryption_enabled = false
redis_snapshot_retention_limit   = 0
redis_snapshot_window            = "17:00-18:00"
redis_maintenance_window         = "tue:18:00-tue:19:00"
redis_auto_minor_version_upgrade = true
