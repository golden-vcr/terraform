# There is no officially-supported Terraform provider for the Twitch API, but to keep
# all our secrets in one place and unify our configuration process, Twitch API
# credentials are still stored in Terraform state.

variable twitch_channel_name {
  description = "Name of the Twitch channel for which webhook subscriptions should be registered"
  default     = "goldenvcr"
}

variable twitch_app_client_id {
  description = "Client ID value for Twitch Application, obtained from https://dev.twitch.tv/console/apps; should be set in secret.auto.tfvars"
}

variable twitch_app_client_secret {
  description = "Client Secret value for Twitch Application, obtained from https://dev.twitch.tv/console/apps; should be set in secret.auto.tfvars"
  sensitive   = true
}

variable twitch_extension_client_id {
  description = "Client ID vlaue for Twitch Extension, obtained from https://dev.twitch.tv/console/extensions; should be set in secret.auto.tfvars"
}

variable twitch_bot_username {
  description = "Name of the Twitch account for our chat bot"
  default     = "tapeboy"
}

variable twitch_bot_client_id {
  description = "Client ID value for our chat bot's Twitch Application, obtained from https://dev.twitch.tv/console/apps; should be set in secret.auto.tfvars"
  sensitive   = true
}

variable twitch_bot_client_secret {
  description = "Client Secret value for our chat bot's Twitch Application, obtained from https://dev.twitch.tv/console/apps; should be set in secret.auto.tfvars"
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
TWITCH_EXTENSION_CLIENT_ID=${var.twitch_extension_client_id}
TWITCH_WEBHOOK_SECRET=${random_id.twitch_webhook_secret.hex}
EOT
  sensitive = true
}

output "twitch_extension_client_env" {
  value     = <<EOT
TWITCH_EXTENSION_CLIENT_ID=${var.twitch_extension_client_id}
EOT
  sensitive = true
}
