env    = "dev"
domain = "yourdomain.com"

# Sensitive — do not commit real values
cloudflare_api_token = ""
cloudflare_zone_id   = ""

# Fill in after EKS + AWS Load Balancer Controller is deployed
# Run: kubectl get ingress -n <namespace>
alb_dns_name = ""
