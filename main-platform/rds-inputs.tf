variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_engine_version" {
  type    = string
  default = "17"
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_username" {
  type    = string
  default = "app_user"
}

variable "enable_rds_replica" {
  description = "Set to true to create a read replica (adds cost, use for UAT/PROD validation)"
  type        = bool
  default     = false
}
