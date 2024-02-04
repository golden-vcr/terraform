locals {
  # Common env vars used by this service in all environments
  env_ledger = <<EOT
TWITCH_CLIENT_ID=${var.twitch_app_client_id}
TWITCH_CLIENT_SECRET=${var.twitch_app_client_secret}
EOT
}

# The deploy script will write this value to an .env file on the remote host
output "env_ledger" {
  value       = "${local.env_ledger}${local.db_env_ledger}"
  description = ".env file contents for the ledger service when running in a live environment"
  sensitive   = true
}

# To populate a ledger/.env file for local development:
#   terraform output -raw env_ledger_local > ../ledger/.env
output "env_ledger_local" {
  value       = "${local.env_ledger}${local.db_env_local}"
  description = ".env file contents for the ledger service when running locally"
  sensitive   = true
}
