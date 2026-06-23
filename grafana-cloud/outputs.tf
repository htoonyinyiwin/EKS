output "stack_url" {
  description = "URL of the Grafana Cloud stack."
  value       = grafana_cloud_stack.this.url
}

output "stack_id" {
  description = "Numeric ID of the Grafana Cloud stack."
  value       = grafana_cloud_stack.this.id
}

output "stack_slug" {
  description = "Slug of the Grafana Cloud stack."
  value       = grafana_cloud_stack.this.slug
}
