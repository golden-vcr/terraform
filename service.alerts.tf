locals {
  # Common env vars used by this service in all environments
  env_alerts = ""
}

# The deploy script will write this value to an .env file on the remote host
output "env_alerts" {
  value       = "${local.env_alerts}${local.rmq_env_alerts}"
  description = ".env file contents for the alerts service when running in a live environment"
  sensitive   = true
}

# To populate a alerts/.env file for local development:
#   terraform output -raw env_alerts_local > ../alerts/.env
output "env_alerts_local" {
  value       = "${local.env_alerts}${local.rmq_env_local}"
  description = ".env file contents for the alerts service when running locally"
  sensitive   = true
}
