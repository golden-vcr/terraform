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
