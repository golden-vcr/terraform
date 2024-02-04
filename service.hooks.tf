# Generate a secret value used to authenticate Twitch EventSub webhook calls
resource "random_id" "hooks_webhook_secret" {
  keepers = {
    channel_name = var.twitch_channel_name
    version      = 1
  }
  byte_length = 32
}

locals {
  # Common env vars used by this service in all environments
  env_hooks = <<EOT
TWITCH_CHANNEL_NAME=${var.twitch_channel_name}
TWITCH_CLIENT_ID=${var.twitch_app_client_id}
TWITCH_CLIENT_SECRET=${var.twitch_app_client_secret}
TWITCH_WEBHOOK_SECRET=${random_id.hooks_webhook_secret.hex}
EOT
}

# The deploy script will write this value to an .env file on the remote host
output "env_hooks" {
  value       = "${local.env_hooks}${local.rmq_env_hooks}"
  description = ".env file contents for the hooks service when running in a live environment"
  sensitive   = true
}

# To populate a hooks/.env file for local development:
#   terraform output -raw env_hooks_local > ../hooks/.env
#   ./local-rmq.sh env >> ../hooks/.env
output "env_hooks_local" {
  value       = local.env_hooks
  description = ".env file contents for the hooks service when running locally"
  sensitive   = true
}
