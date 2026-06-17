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

variable "redis_replication_group" {
  description = "Set to 1 to create an ElastiCache Replication Group, 0 to create a single node cluster"
  type        = number
}

variable "redis_single_node_cluster" {
  description = "Set to 1 to create a single node Redis cluster, 0 to not create it"
  type        = number
}

variable "multi_az_enabled" {
  description = "Whether to enable Multi-AZ for the Redis replication group"
  type        = bool
}

variable "automatic_failover_enabled" {
  description = "Whether to enable automatic failover for the Redis replication group"
  type        = bool
}

variable "num_node_groups" {
  description = "Number of node groups (shards) for the Redis replication group"
  type        = number
}

variable "replicas_per_node_group" {
  description = "Number of replicas per node group (shard) for the Redis replication group"
  type        = number
}

variable "num_cache_clusters" {
  description = "Number of cache clusters (nodes) in the replication group"
  type        = number
}

variable "redis_engine" {
  description = "Redis engine version (e.g., 7.0)"
  type        = string
}

variable "redis_at_rest_encryption_enabled" {
  description = "Enable at-rest encryption for the Redis cluster"
  type        = bool
}

variable "redis_transit_encryption_enabled" {
  description = "Enable in-transit encryption for the Redis cluster"
  type        = bool
}

variable "redis_snapshot_retention_limit" {
  description = "Number of days to retain automatic snapshots"
  type        = number
}

variable "redis_snapshot_window" {
  description = "Daily time range (in UTC) during which ElastiCache begins taking a daily snapshot of your cluster"
  type        = string
}

variable "redis_maintenance_window" {
  description = "Weekly time range (in UTC) during which maintenance on the cluster is performed"
  type        = string
}

variable "redis_auto_minor_version_upgrade" {
  description = "Whether to enable automatic minor version upgrades for the Redis cluster"
  type        = bool
}
