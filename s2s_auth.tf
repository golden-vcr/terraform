# Secret key shared between ledger and showtime to facilitate basic service-to-service
# auth
resource "random_password" "ledger_showtime_secret_key" {
  keepers = {
    version  = 1
  }
  special = false
  length  = 64
}

output "ledger_s2s_auth_env" {
  value     = <<EOT
LEDGER_SHOWTIME_SECRET_KEY=${random_password.ledger_showtime_secret_key.result}
EOT
  sensitive = true
}
