# Requests that hit Cloudflare should be directed straight to our single DigitalOcean
# droplet, which runs the backend API for our app
resource "cloudflare_record" "root_a" {
  zone_id = var.cloudflare_zone_id
  name    = "${var.domain}."
  value   = digitalocean_droplet.api.ipv4_address
  type    = "A"
  ttl     = 1
  proxied = true
}

# Create an identical A record for the www subdomain: we'll handle path rewrites etc.
# in our nginx server
resource "cloudflare_record" "www_a" {
  zone_id = var.cloudflare_zone_id
  name    = "www.${var.domain}."
  value   = digitalocean_droplet.api.ipv4_address
  type    = "A"
  ttl     = 1
  proxied = true
}
