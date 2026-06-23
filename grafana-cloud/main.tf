resource "grafana_cloud_stack" "this" {
  provider    = grafana.cloud
  name        = var.stack_name
  slug        = var.stack_slug
  region_slug = var.region_slug

  lifecycle {
    prevent_destroy = true
  }
}

resource "grafana_cloud_stack_service_account" "this" {
  provider    = grafana.cloud
  stack_slug  = grafana_cloud_stack.this.slug
  name        = "terraform-managed-app"
  role        = "Admin"
  is_disabled = false
}

resource "grafana_cloud_stack_service_account_token" "this" {
  provider           = grafana.cloud
  stack_slug         = grafana_cloud_stack.this.slug
  service_account_id = grafana_cloud_stack_service_account.this.id
  name               = "terraform-token"
}

# Proof-of-life stack-level resource — confirms the stack provider is wired correctly
resource "grafana_folder" "general" {
  provider = grafana.stack
  title    = "General-EKS"
}
