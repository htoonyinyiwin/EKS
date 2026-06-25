variable "env" {
  description = "Environment name."
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR (Classless Inter-Domain Routing)."
  type        = string
}

variable "azs" {
  description = "Availability zones for subnets."
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR ranges for private subnets."
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDR ranges for public subnets."
  type        = list(string)
}

variable "private_subnet_tags" {
  description = "Private subnet tags."
  type        = map(any)
}

variable "public_subnet_tags" {
  description = "Public subnet tags."
  type        = map(any)
}

variable "project_name" {
  type = string
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

variable "ecr_replication_destination_prod_account_id" {
  description = "Target AWS account ID for ECR replication (prod account)"
  type        = string
  default     = ""
}

variable "ecr_replication_destination_dev_account_id" {
  description = "Dev AWS account ID for ECR replication"
  type        = string
  default     = ""
}

variable "ecr_source_account_id" {
  description = "Source AWS account ID allowed to replicate images (dev account)"
  type        = string
  default     = ""
}

# Budget
variable "budget_alert_email" {
  description = "Email address to receive budget alert notifications"
  type        = string
}