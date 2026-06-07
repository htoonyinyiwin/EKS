variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_zone_id" {
  type      = string
  sensitive = true
}

variable "domain" {
  type        = string
  description = "Root domain managed in Cloudflare (e.g. example.com)"
}

variable "env" {
  type    = string
  default = "dev"
}

# Filled in after main-platform apply (terraform output from AWS LB controller)
variable "alb_dns_name" {
  type        = string
  description = "ALB DNS name from AWS — get after EKS + LB controller is deployed"
}
