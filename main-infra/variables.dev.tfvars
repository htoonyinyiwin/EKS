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
# docker_hub_username         = "brianaung"

# ECR
ecr_images_to_retain                        = 10
count_ecr_replication_configuration         = 0 # dev is not the source
count_ecr_registry_policy                   = 0 # dev is not a replication target
ecr_replication_destination_prod_account_id = ""
ecr_replication_destination_dev_account_id  = ""
ecr_source_account_id                       = ""

budget_alert_email = "brianaung95@gmail.com"
