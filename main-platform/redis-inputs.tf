variable "redis_node_type" {
  description = "Redis node_type"
  type        = string
}

variable "redis_parameter_group_name" {
  description = "Redis parameter group to use (e.g., default.redis7)"
  type        = string
}

variable "redis_engine_version" {
  description = "Redis engine version (e.g., 7.0)"
  type        = string
}

variable "redis_apply_immediately" {
  description = "Whether to apply changes immediately"
  type        = bool
}

variable "redis_num_cache_nodes" {
  description = "Number of cache nodes (use 1 for non-clustered Redis)"
  type        = number
}

variable "redis_port" {
  description = "Redis port"
  type        = number
}

variable "redis_single_node_cluster" {
  description = "Set to 1 to create a single node Redis cluster, 0 to not create it"
  type        = number
}

variable "enable_redis_replication" {
  description = "Set to true to create a Redis replication group (adds cost, use for UAT/PROD validation)"
  type        = bool
  default     = false
}
