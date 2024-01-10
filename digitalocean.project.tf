resource "digitalocean_project" "golden_vcr" {
  name        = "golden-vcr"
  description = "Golden VCR webapp"
  purpose     = "Web Application"
  environment = "Production"
  resources   = [
    digitalocean_droplet.api.urn,
    digitalocean_droplet.rabbitmq_server.urn,
    digitalocean_volume.data.urn,
    digitalocean_spaces_bucket.frontend.urn,
    digitalocean_spaces_bucket.graphics.urn,
    digitalocean_spaces_bucket.images.urn,
    digitalocean_spaces_bucket.user_images.urn,
  ]
}
