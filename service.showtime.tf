locals {
  # Common env vars used by this service in all environments
  env_showtime = <<EOT
TWITCH_CHANNEL_NAME=${var.twitch_channel_name}
TWITCH_CLIENT_ID=${var.twitch_app_client_id}
TWITCH_CLIENT_SECRET=${var.twitch_app_client_secret}
TWITCH_EXTENSION_CLIENT_ID=${var.twitch_extension_client_id}
TWITCH_WEBHOOK_SECRET=${random_id.twitch_webhook_secret.hex}
OPENAI_API_KEY=${var.openai_api_key}
DISCORD_GHOSTS_WEBHOOK_URL=${var.discord_ghosts_webhook_url}
SPACES_BUCKET_NAME=${digitalocean_spaces_bucket.user_images.name}
SPACES_REGION_NAME=${digitalocean_spaces_bucket.user_images.region}
SPACES_ENDPOINT_URL=${digitalocean_spaces_bucket.user_images.endpoint}
SPACES_ACCESS_KEY_ID=${var.digitalocean_spaces_key_id}
SPACES_SECRET_KEY=${var.digitalocean_spaces_secret}
AUTH_SHARED_SECRET=${random_password.auth_shared_secret.result}
EOT
}

# The deploy script will write this value to an .env file on the remote host
output "env_showtime" {
  value       = "${local.env_showtime}${local.db_env_showtime}"
  description = ".env file contents for the showtime service when running in a live environment"
  sensitive   = true
}

# To populate a showtime/.env file for local development:
#   terraform output -raw env_showtime_local > ../showtime/.env
output "env_showtime_local" {
  value       = "${local.env_showtime}${local.db_env_local}"
  description = ".env file contents for the showtime service when running locally"
  sensitive   = true
}
