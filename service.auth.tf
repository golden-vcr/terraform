# Generate a cryptographic key that's known only to the auth service: the auth server
# uses this key to sign JWTs that it issues to other services
resource "tls_private_key" "auth" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Generate a random ID to use as the 'kid' value when identifying that key as a JWK
resource "random_id" "auth_kid" {
  keepers = {
    public_key = tls_private_key.auth.public_key_pem
  }
  byte_length = 24
}

# Format the corresponding public key as a JWK set that can be advertised by this
# service at /.well-known/jwks.json: when a client needs to verify an
# auth-service-issued JWT, it can find the corresponding public key and use it to verify
# the JWT from its signature
data "jwks_from_key" "auth" {
  key = tls_private_key.auth.public_key_pem
  kid = random_id.auth_kid.hex
  use = "sig"
  alg = "RS256"
}

# Also generate a shared secret that's used for symmetric encryption between services:
# when a service like dispatch needs to request a JWT from the auth service, it sends a
# payload that's HMAC-encrypted with this secret. The auth service decodes the payload
# using the same secret, verifying that the request is coming from an internal service
# that knows the shared secret.
resource "random_password" "auth_shared_secret" {
  keepers = {
    version  = 1
  }
  special = false
  length  = 64
}



locals {
  # Common env vars used by this service in all environments
  env_auth = <<EOT
TWITCH_CHANNEL_NAME=${var.twitch_channel_name}
TWITCH_CLIENT_ID=${var.twitch_app_client_id}
TWITCH_CLIENT_SECRET=${var.twitch_app_client_secret}
AUTH_SIGNING_KEY_ID=${random_id.auth_kid.hex}
AUTH_SIGNING_KEY_PEM=${jsonencode(tls_private_key.auth.private_key_pem)}
AUTH_JWKS_JSON=${jsonencode(jsonencode({keys = [jsondecode(data.jwks_from_key.auth.jwks)]}))}
AUTH_SHARED_SECRET=${random_password.auth_shared_secret.result}
EOT
}

# The deploy script will write this value to an .env file on the remote host
output "env_auth" {
  value       = "${local.env_auth}${local.db_env_auth}"
  description = ".env file contents for the auth service when running in a live environment"
  sensitive   = true
}

# To populate a auth/.env file for local development:
#   terraform output -raw env_auth_local > ../auth/.env
output "env_auth_local" {
  value       = "${local.env_auth}${local.db_env_local}"
  description = ".env file contents for the auth service when running locally"
  sensitive   = true
}

# Legacy: used by showtime
output "auth_shared_secret_env" {
  value     = <<EOT
AUTH_SHARED_SECRET=${random_password.auth_shared_secret.result}
EOT
  sensitive = true
}
