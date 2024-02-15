locals {
  # Common env vars used by this service in all environments
  env_remix = ""
}

# The deploy script will write this value to an .env file on the remote host
output "env_remix" {
  value       = "${local.env_remix}${local.db_env_remix}"
  description = ".env file contents for the remix service when running in a live environment"
  sensitive   = true
}

# To populate a remix/.env file for local development:
#   terraform output -raw env_remix_local > ../remix/.env
output "env_remix_local" {
  value       = "${local.env_remix}${local.db_env_local}"
  description = ".env file contents for the remix service when running locally"
  sensitive   = true
}
