variable "env" {
  type = string
}

variable "project_name" {
  type = string
}

variable "vpc_id" {
  type        = string
  description = "VPC ID from main-infra"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs from main-infra — worker nodes run here"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs from main-infra"
}

variable "eks_version" {
  type        = string
  description = "Kubernetes version"
}

variable "instance_types" {
  type        = list(string)
  description = "EC2 instance types for worker nodes"
  default     = ["t3a.medium"]
}

variable "desired_size" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

variable "disk_size" {
  type        = number
  description = "EBS root volume size in GB for worker nodes"
  default     = 20
}

variable "admin_iam_arns" {
  type        = list(string)
  description = "IAM user/role ARNs to grant cluster admin access (kubectl)"
  default     = []
}
