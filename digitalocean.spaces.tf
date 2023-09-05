resource "digitalocean_spaces_bucket" "frontend" {
  name   = "golden-vcr-frontend"
  region = "nyc3"
  acl    = "public-read"
}
