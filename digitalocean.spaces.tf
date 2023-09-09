resource "digitalocean_spaces_bucket" "frontend" {
  name   = "golden-vcr-frontend"
  region = "nyc3"
  acl    = "public-read"
}

resource "digitalocean_spaces_bucket" "images" {
  name   = "golden-vcr-images"
  region = "nyc3"
  acl    = "public-read"
}

output "frontend_s3_env" {
  value     = <<EOT
SPACES_BUCKET_NAME=${digitalocean_spaces_bucket.frontend.name}
SPACES_REGION_NAME=${digitalocean_spaces_bucket.frontend.region}
SPACES_ENDPOINT_URL=${digitalocean_spaces_bucket.frontend.endpoint}
SPACES_ACCESS_KEY_ID=${var.digitalocean_spaces_key_id}
SPACES_SECRET_KEY=${var.digitalocean_spaces_secret}
EOT
  sensitive = true
}

output "images_s3_env" {
  value     = <<EOT
SPACES_BUCKET_NAME=${digitalocean_spaces_bucket.images.name}
SPACES_REGION_NAME=${digitalocean_spaces_bucket.images.region}
SPACES_ENDPOINT_URL=${digitalocean_spaces_bucket.images.endpoint}
SPACES_ACCESS_KEY_ID=${var.digitalocean_spaces_key_id}
SPACES_SECRET_KEY=${var.digitalocean_spaces_secret}
EOT
  sensitive = true
}
