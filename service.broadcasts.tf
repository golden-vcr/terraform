locals {
  # Common env vars used by this service in all environments
  env_broadcasts = <<EOT
DISCORD_NOTIFICATIONS_WEBHOOK_URL=${var.discord_notifications_webhook_url}
EOT
}

# The deploy script will write this value to an .env file on the remote host
output "env_broadcasts" {
  value       = "${local.env_broadcasts}${local.db_env_broadcasts}${local.rmq_env_broadcasts}"
  description = ".env file contents for the broadcasts service when running in a live environment"
  sensitive   = true
}

# To populate a broadcasts/.env file for local development:
#   terraform output -raw env_broadcasts_local > ../broadcasts/.env
output "env_broadcasts_local" {
  value       = "${local.env_broadcasts}${local.db_env_local}${local.rmq_env_local}"
  description = ".env file contents for the broadcasts service when running locally"
  sensitive   = true
}
