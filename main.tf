variable "domain" {
  type        = string
  description = "Root domain name for our application"
  default     = "goldenvcr.com"
}

terraform {
  required_providers {
    tls = {
      source = "hashicorp/tls"
      version = "~> 4.0"
    }
    jwks = {
      source = "iwarapter/jwks"
      version = "0.1.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    google = {
      version = "~> 4.80"
    }
  }
}
