resource "cloudflare_dns_record" "app" {
  zone_id = var.cloudflare_zone_id
  name    = "app.${var.domain}"
  type    = "CNAME"
  content = var.alb_dns_name
  proxied = true
  ttl     = 1 # auto when proxied = true

  comment = "EKS app — ${var.env}"
}
