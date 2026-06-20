env          = "prod"
project_name = "eks"

# VPC
azs                         = ["ap-northeast-1a", "ap-northeast-1c"]
vpc_cidr_block              = "10.10.0.0/22"
private_subnets             = ["10.10.1.0/26", "10.10.1.64/26"]
public_subnets              = ["10.10.0.0/27", "10.10.0.32/27"]
private_subnet_tags         = {}
public_subnet_tags          = {}
count_eip                   = 0
public_internet_cidr_blocks = ["0.0.0.0/0"]
# docker_hub_username         = "brianaung"

# ECR
ecr_images_to_retain                   = 10
count_ecr_replication_configuration    = 0 # prod is not the source
count_ecr_registry_policy              = 0 # set to 1 to allow uat to replicate here
ecr_replication_destination_account_id = ""
ecr_source_account_id                  = "051602877369" # uat account
