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
