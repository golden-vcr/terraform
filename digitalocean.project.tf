resource "digitalocean_project" "golden_vcr" {
  name        = "golden-vcr"
  description = "Golden VCR webapp"
  purpose     = "Web Application"
  environment = "Production"
  resources   = [
    digitalocean_droplet.api.urn,
    digitalocean_volume.db.urn,
    digitalocean_spaces_bucket.frontend.urn,
    digitalocean_spaces_bucket.graphics.urn,
    digitalocean_spaces_bucket.images.urn,
  ]
}
