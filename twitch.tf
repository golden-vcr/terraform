# There is no officially-supported Terraform provider for the Twitch API, so we manage
# Twitch EventSub resources outside of Terraform, using an 'init' binary in the
# showtime repo. However, to keep all our secrets in one place and unify our
# configuration process, Twitch API credentials are still stored in Terraform state.

variable twitch_channel_name {
  description = "Name of the Twitch channel for which webhook subscriptions should be registered"
  default     = "goldenvcr"
}

variable twitch_app_client_id {
  description = "Client ID value for Twitch Application, obtained from https://dev.twitch.tv/console/apps; should be set in secret.auto.tfvars"
  sensitive   = true
}

variable twitch_app_client_secret {
  description = "Client Secret value for Twitch Application, obtained from https://dev.twitch.tv/console/apps; should be set in secret.auto.tfvars"
  sensitive   = true
}

resource "random_id" "twitch_webhook_secret" {
  keepers ={
    channel_name = var.twitch_channel_name
    version      = 1
  }
  byte_length = 32
}

output "twitch_api_env" {
  value     = <<EOT
TWITCH_CHANNEL_NAME=${var.twitch_channel_name}
TWITCH_CLIENT_ID=${var.twitch_app_client_id}
TWITCH_CLIENT_SECRET=${var.twitch_app_client_secret}
TWITCH_WEBHOOK_SECRET=${random_id.twitch_webhook_secret.hex}
EOT
  sensitive = true
}
