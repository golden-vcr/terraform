terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
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

provider "digitalocean" {
  token = var.digitalocean_token
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
