locals {
  # Common env vars used by this service in all environments
  env_dynamo = <<EOT
AUTH_SHARED_SECRET=${random_password.auth_shared_secret.result}
OPENAI_API_KEY=${var.openai_api_key}
DISCORD_GHOSTS_WEBHOOK_URL=${var.discord_ghosts_webhook_url}
DISCORD_FRIENDS_WEBHOOK_URL=${var.discord_friends_webhook_url}
SPACES_BUCKET_NAME=${digitalocean_spaces_bucket.user_images.name}
SPACES_REGION_NAME=${digitalocean_spaces_bucket.user_images.region}
SPACES_ENDPOINT_URL=${digitalocean_spaces_bucket.user_images.endpoint}
SPACES_ACCESS_KEY_ID=${var.digitalocean_spaces_key_id}
SPACES_SECRET_KEY=${var.digitalocean_spaces_secret}
EOT
}

# The deploy script will write this value to an .env file on the remote host
output "env_dynamo" {
  value       = "${local.env_dynamo}${local.db_env_dynamo}${local.rmq_env_dynamo}"
  description = ".env file contents for the dynamo service when running in a live environment"
  sensitive   = true
}

# To populate a dynamo/.env file for local development:
#   terraform output -raw env_dynamo_local > ../dynamo/.env
output "env_dynamo_local" {
  value       = "${local.env_dynamo}${local.db_env_local}${local.rmq_env_local}"
  description = ".env file contents for the dynamo service when running locally"
  sensitive   = true
}
