locals {
  # Common env vars used by this service in all environments
  env_dispatch = <<EOT
AUTH_SHARED_SECRET=${random_password.auth_shared_secret.result}
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
#   ./local-rmq.sh env >> ../dispatch/.env
output "env_dispatch_local" {
  value       = local.env_dispatch
  description = ".env file contents for the dispatch service when running locally"
  sensitive   = true
}
