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
  type    = string
}

variable "count_eip" {
  description = "Number of EIPs to create for NAT gateways."
  type        = number
}

variable "public_internet_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the internet"
  type        = list(string)
}