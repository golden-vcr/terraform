# Generate a key (to be stored in terraform state) with which we can sign our
# origin certificate
resource "tls_private_key" "goldenvcr" {
  algorithm = "RSA"
}

resource "tls_cert_request" "goldenvcr" {
  private_key_pem = tls_private_key.goldenvcr.private_key_pem

  subject {
    common_name  = ""
    organization = "Golden VCR"
  }
}

# Create a Cloudflare Origin Certificate: this cert is installed on our origin server
# (i.e. the DigitalOcean droplet) and is used to encrypt traffic between CloudFlare and
# our server.
resource "cloudflare_origin_ca_certificate" "goldenvcr" {
  csr                  = tls_cert_request.goldenvcr.cert_request_pem
  hostnames            = ["goldenvcr.com"]
  request_type         = "origin-rsa"
  requested_validity   = 365
  min_days_for_renewal = 7
}

# Expose origin cert and key as outputs so we can install them on our nginx server
output "goldenvcr_ssl_certificate" {
  value     = cloudflare_origin_ca_certificate.goldenvcr.certificate
  sensitive = true
}

output "goldenvcr_ssl_certificate_key" {
  value     = tls_private_key.goldenvcr.private_key_pem
  sensitive = true
}

# Configure the default zone for goldenvcr.com to enable (and require) HTTPS
resource "cloudflare_zone_settings_override" "default" {
  zone_id = var.cloudflare_zone_id
  
  settings {
    tls_1_3                  = "on"
    automatic_https_rewrites = "on"
    always_use_https         = "on"
    ssl                      = "strict"
  }
}
