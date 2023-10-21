variable "domain" {
  type        = string
  description = "Root domain name for our application"
  default     = "goldenvcr.com"
}

terraform {
  required_providers {
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
