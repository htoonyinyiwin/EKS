terraform {
  required_version = ">= 1.5.0"

  backend "s3" {}

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 4.39"
    }
  }
}
