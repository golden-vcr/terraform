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

variable "digitalocean_token" {
  type        = string
  description = "API token created via the DigitalOcean web UI; should be set in secret.auto.tfvars"
  sensitive   = true
}

variable "digitalocean_spaces_key_id" {
  type        = string
  description = "ID for Spaces Key created via the DigitalOcean web UI; should be set in secret.auto.tfvars"
  sensitive   = true
}

variable "digitalocean_spaces_secret" {
  type        = string
  description = "Secret value for Spaces Key created via the DigitalOcean web UI; should be set in secret.auto.tfvars"
  sensitive   = true
}

provider "digitalocean" {
  token             = var.digitalocean_token
  spaces_access_id  = var.digitalocean_spaces_key_id
  spaces_secret_key = var.digitalocean_spaces_secret
}

variable "domain" {
  type        = string
  description = "Root domain name for our application"
  default     = "goldenvcr.com"
}

variable "cloudflare_token" {
  type        = string
  description = "API token created via https://dash.cloudflare.com/profile/api-tokens; should be set in secret.auto.tfvars"
  sensitive   = true
}

variable "cloudflare_zone_id" {
  type        = string
  description = "Zone ID value from the domain overview at dash.cloudflare.com; should be set in secret.auto.tfvars"
  sensitive   = true
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}

variable "google_project_name" {
  type        = string
  description = "Name of the project created via the web UI at https://console.cloud.google.com"
  default     = "golden-vcr-api"
}

provider "google" {
  project               = var.google_project_name
  region                = "us-central1"
  zone                  = "us-central1-c"
  user_project_override = true
}
