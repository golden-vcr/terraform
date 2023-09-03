resource "digitalocean_project" "golden_vcr" {
  name        = "golden-vcr"
  description = "Golden VCR webapp"
  purpose     = "Web Application"
  environment = "Production"
  resources   = [
    digitalocean_droplet.api.urn,
  ]
}
