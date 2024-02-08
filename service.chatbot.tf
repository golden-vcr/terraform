locals {
  # Common env vars used by this service in all environments
  env_chatbot = <<EOT
TWITCH_CHANNEL_NAME=${var.twitch_channel_name}
TWITCH_BOT_USERNAME=${var.twitch_bot_username}
TWITCH_BOT_CLIENT_ID=${var.twitch_bot_client_id}
TWITCH_BOT_CLIENT_SECRET=${var.twitch_bot_client_secret}
AUTH_SHARED_SECRET=${random_password.auth_shared_secret.result}
EOT
}

# The deploy script will write this value to an .env file on the remote host
output "env_chatbot" {
  value       = "${local.env_chatbot}${local.rmq_env_chatbot}"
  description = ".env file contents for the chatbot service when running in a live environment"
  sensitive   = true
}

# To populate a chatbot/.env file for local development:
#   terraform output -raw env_chatbot_local > ../chatbot/.env
output "env_chatbot_local" {
  value       = "PUBLIC_URL=http://localhost:5006\n${local.env_chatbot}${local.rmq_env_local}"
  description = ".env file contents for the chatbot service when running locally"
  sensitive   = true
}
