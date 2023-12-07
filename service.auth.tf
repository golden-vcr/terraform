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

# Format the corresponding public key as a JWK
data "jwks_from_key" "auth" {
  key = tls_private_key.auth.public_key_pem
  kid = random_id.auth_kid.hex
  use = "sig"
  alg = "RS256"
}

# Format all keys into a JWK set that can be advertised by this service at
# /.well-known/jwks.json: when a client needs to verify an auth-service-issued JWT, it
# can find the corresponding public key and use it to verify the JWT from its signature
output "auth_jwks" {
  value = jsonencode({
    keys = [jsondecode(data.jwks_from_key.auth.jwks)]
  })
  sensitive = true
}

output "auth_signing_keys_env" {
  value     = <<EOT
AUTH_SIGNING_KEY_ID=${random_id.auth_kid.hex}
AUTH_SIGNING_KEY_PEM=${jsonencode(tls_private_key.auth.private_key_pem)}
AUTH_JWKS_JSON=${jsonencode(jsonencode({keys = [jsondecode(data.jwks_from_key.auth.jwks)]}))}
EOT
  sensitive = true
}

# Also generate a shared secret that's used for symmetric encryption between services:
# when a service like showtime needs to request a JWT from the auth service, it sends a
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

output "auth_shared_secret_env" {
  value     = <<EOT
AUTH_SHARED_SECRET=${random_password.auth_shared_secret.result}
EOT
  sensitive = true
}
