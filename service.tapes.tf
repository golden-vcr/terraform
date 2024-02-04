locals {
  # Common env vars used by this service in all environments
  env_tapes = <<EOT
SHEETS_API_KEY=${google_apikeys_key.sheets.key_string}
SPREADSHEET_ID=${var.spreadsheet_id}
SPACES_BUCKET_NAME=${digitalocean_spaces_bucket.images.name}
SPACES_REGION_NAME=${digitalocean_spaces_bucket.images.region}
SPACES_ENDPOINT_URL=${digitalocean_spaces_bucket.images.endpoint}
SPACES_ACCESS_KEY_ID=${var.digitalocean_spaces_key_id}
SPACES_SECRET_KEY=${var.digitalocean_spaces_secret}
TWITCH_CLIENT_ID=${var.twitch_app_client_id}
TWITCH_CLIENT_SECRET=${var.twitch_app_client_secret}
TWITCH_EXTENSION_CLIENT_ID=${var.twitch_extension_client_id}
EOT
}

# The deploy script will write this value to an .env file on the remote host
output "env_tapes" {
  value       = "${local.env_tapes}${local.db_env_tapes}"
  description = ".env file contents for the tapes service when running in a live environment"
  sensitive   = true
}

# To populate a tapes/.env file for local development:
#   terraform output -raw env_tapes_local > ../tapes/.env
output "env_tapes_local" {
  value       = "${local.env_tapes}${local.db_env_local}"
  description = ".env file contents for the tapes service when running locally"
  sensitive   = true
}
