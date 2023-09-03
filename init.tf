terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "digitalocean_token" {
  type        = string
  description = "API token created via the DigitalOcean web UI; should be set in secret.auto.tfvars"
  sensitive   = true
}

provider "digitalocean" {
  token = var.digitalocean_token
}
