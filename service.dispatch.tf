locals {
  # Common env vars used by this service in all environments
  env_dispatch = <<EOT
TWITCH_CLIENT_ID=${var.twitch_app_client_id}
TWITCH_CLIENT_SECRET=${var.twitch_app_client_secret}
EOT
}

# The deploy script will write this value to an .env file on the remote host
output "env_dispatch" {
  value       = "${local.env_dispatch}${local.rmq_env_dispatch}"
  description = ".env file contents for the dispatch service when running in a live environment"
  sensitive   = true
}

# To populate a dispatch/.env file for local development:
#   terraform output -raw env_dispatch_local > ../dispatch/.env
output "env_dispatch_local" {
  value       = "${local.env_dispatch}${local.rmq_env_local}"
  description = ".env file contents for the dispatch service when running locally"
  sensitive   = true
}
