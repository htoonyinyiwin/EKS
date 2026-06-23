variable "cloud_access_policy_token" {
  type        = string
  description = "Grafana Cloud access policy token. Supply via TF_VAR_cloud_access_policy_token env var — never commit to git."
  sensitive   = true
}

variable "stack_name" {
  type        = string
  description = "Display name for the Grafana Cloud stack."
}

variable "stack_slug" {
  type        = string
  description = "Unique slug for the Grafana Cloud stack. Immutable after creation — changing it forces full stack recreation."
}

variable "region_slug" {
  type        = string
  description = "Grafana Cloud region slug (e.g. us, eu, au, prod-gb-south-0). Immutable after creation."
  default     = "us"
}
