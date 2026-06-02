variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "env" {
  type = string
}

variable "project_name" {
  type = string
}

# EKS
variable "eks_version" {
  type = string
}

variable "instance_types" {
  type    = list(string)
  default = ["t3a.medium"]
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
  type    = number
  default = 20
}
