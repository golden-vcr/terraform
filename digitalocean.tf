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
