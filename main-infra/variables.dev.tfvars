# tfvars files in this Architecture is designed to be used for values that can be varied by environment.
# This file is for the development environment.

env          = "dev"
project_name = "eks"

# VPC
azs                         = ["ap-northeast-1a", "ap-northeast-1c"]
vpc_cidr_block              = "10.10.0.0/22"                    # 1024 IPs (covers all)
private_subnets             = ["10.10.1.0/26", "10.10.1.64/26"] # (64 IPs, 59 usable)
public_subnets              = ["10.10.0.0/27", "10.10.0.32/27"] # (32 IPs, 27 usable)
private_subnet_tags         = {}
public_subnet_tags          = {}
count_eip                   = 0
public_internet_cidr_blocks = ["0.0.0.0/0"]

# ECS
image_url = ""

# RDS
count_read_replica           = 0
allocated_storage            = 200
storage_type                 = "gp2"
iops                         = null
engine                       = "postgres"
engine_version               = "17.4"
instance_class               = "db.t3.micro"
apply_immediately            = true
db_name                      = "core_develop"
username                     = "postgres"
parameter_group_name         = "default.postgres17"
multi_az                     = false
publicly_accessible          = true
allow_major_version_upgrade  = true
skip_final_snapshot          = true
backup_retention_period      = 0
max_allocated_storage        = 1000
performance_insights_enabled = true
storage_encrypted            = true
deletion_protection          = false
backup_window                = "00:00-01:00"         # corresponds to 07:00–08:00 Bangkok UTC
maintenance_window           = "sun:01:00-sun:02:00" # corresponds to Sun 08:00–09:00 Bangkok UTC

# EC2 Bastion Host
keypair_name                    = "dev-bastion-keypair"
volume_size                     = 8
instance_type                   = "t3.micro"
bastion_ssh_ingress_cidr_blocks = ["0.0.0.0/0"]
bastion_ssh_egress_cidr_blocks  = ["0.0.0.0/0"]

bastion_ssh_ingress_cidr_blocks_user1 = ["34.239.73.248/32"]
bastion_ssh_ingress_cidr_blocks_user2 = null

# Redis
redis_node_type            = "cache.t3.micro" #"cache.t4g.medium"
redis_parameter_group_name = "default.redis7"
redis_engine_version       = "7.0"
redis_engine               = "redis"
redis_apply_immediately    = true
redis_num_cache_nodes      = 1
redis_port                 = 6379

redis_single_node_cluster = 1 # 0 for non-prod
redis_replication_group   = 0 # 1 for prod

multi_az_enabled           = false
automatic_failover_enabled = false
num_node_groups            = 1
replicas_per_node_group    = 0
num_cache_clusters         = 0

redis_at_rest_encryption_enabled = false
redis_transit_encryption_enabled = false

redis_snapshot_retention_limit   = 3
redis_snapshot_window            = "17:00-18:00"         # corresponds to 00:00–01:00 Bangkok UTC
redis_maintenance_window         = "tue:18:00-tue:19:00" # corresponds to Wed 01:00–02:
redis_auto_minor_version_upgrade = true

# ECR
count_ecr_repository                = 1
count_ecr_registry_policy           = 0 # Dev environment is set 0 since it is the source
count_ecr_replication_configuration = 0 # set to 0 from 1, after discussion with Okkami team, that to go with separate docker image-ECR approach

ecr_countnumber_to_retain = 10
repository_name           = "fingi-core7-app"
repository_filter         = "fingi-core7-app"

# Route53
count_route53_zone = 1
r53_domain_name    = "vnb.com"

# ACM
subject_alternative_names = ["*.aws-develop.vnb.com"]
domain_name               = "vnb.com"

# IAM OIDC
thumbprint_list = ["c31f72d5eb4d8d5bebd1f1ddf4baae01e0779530"]

# S3
s3_name = "eks-s3"