# Account-level provider — manages stacks, service accounts, access policies
provider "grafana" {
  alias                     = "cloud"
  cloud_access_policy_token = var.cloud_access_policy_token
}

# Stack-level provider — manages resources inside the stack (folders, dashboards, data sources)
provider "grafana" {
  alias    = "stack"
  url      = grafana_cloud_stack.this.url
  auth     = grafana_cloud_stack_service_account_token.this.key
  stack_id = grafana_cloud_stack.this.id
}
