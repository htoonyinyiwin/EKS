output "vpc_id" {
  value       = module.infra.vpc_id
  description = "VPC ID — pass to main-app variables.dev.tfvars"
}

output "private_subnet_ids" {
  value       = module.infra.private_subnet_ids
  description = "Private subnet IDs — pass to main-app variables.dev.tfvars"
}

output "public_subnet_ids" {
  value       = module.infra.public_subnet_ids
  description = "Public subnet IDs — pass to main-app variables.dev.tfvars"
}
