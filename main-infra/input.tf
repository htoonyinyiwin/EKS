variable "env" {
  type = string
}

variable "project_name" {
  type = string
}

variable "azs" {
  type    = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1b"]
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


# ECR

# variable "count_ecr_repository" {
#   description = "Number of ECR repositories to create"
#   type        = number
# }

# variable "count_ecr_registry_policy" {
#   description = "Number of ECR replication policies to create"
#   type        = number
# }

# variable "count_ecr_replication_configuration" {
#   description = "Number of ECR replication configurations to create"
#   type        = number
# }

# variable "ecr_countnumber_to_retain" {
#   description = "Number of images to retain in the ECR lifecycle policy"
#   type        = number
# }

# variable "repository_name" {
#   description = "Name of the ECR repository"
#   type        = string
# }


# variable "s3_name" {
#   description = "Base name for S3 bucket"
#   type        = string
# }