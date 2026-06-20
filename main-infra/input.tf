variable "env" {
  type = string
}

variable "project_name" {
  type = string
}

variable "azs" {
  type    = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "vpc_cidr_block" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnet_tags" {
  type = map(string)
}

variable "public_subnet_tags" {
  type = map(string)
}

variable "count_eip" {
  description = "Number of EIPs to create for NAT gateways."
  type        = number
}

variable "public_internet_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the internet"
  type        = list(string)
}

# variable "docker_hub_username" {
#   type = string
# }

variable "ecr_images_to_retain" {
  description = "Number of images to keep per ECR repository"
  type        = number
  default     = 10
}

variable "count_ecr_replication_configuration" {
  description = "Set to 1 in source account (dev) to replicate images to destination account"
  type        = number
  default     = 0
}

variable "count_ecr_registry_policy" {
  description = "Set to 1 in destination accounts (uat/prod) to allow replication from dev"
  type        = number
  default     = 0
}

variable "ecr_replication_destination_account_id" {
  description = "Target AWS account ID for ECR replication (uat or prod account)"
  type        = string
  default     = ""
}

variable "ecr_source_account_id" {
  description = "Source AWS account ID allowed to replicate images (dev account)"
  type        = string
  default     = ""
}
