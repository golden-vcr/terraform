// Bucket where we deploy static builds of the frontend app
resource "digitalocean_spaces_bucket" "frontend" {
  name   = "golden-vcr-frontend"
  region = "nyc3"
  acl    = "public-read"
}

// Bucket where we deploy static builds of the graphics app (i.e. OBS overlay)
resource "digitalocean_spaces_bucket" "graphics" {
  name   = "golden-vcr-graphics"
  region = "nyc3"
  acl    = "public-read"
}

// Bucket where we upload scanned images for each tape
resource "digitalocean_spaces_bucket" "images" {
  name   = "golden-vcr-images"
  region = "nyc3"
  acl    = "public-read"
}

// Bucket where we upload images generated from user submissions during streams
resource "digitalocean_spaces_bucket" "user_images" {
  name   = "golden-vcr-user-images"
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

output "graphics_s3_env" {
  value     = <<EOT
SPACES_BUCKET_NAME=${digitalocean_spaces_bucket.graphics.name}
SPACES_REGION_NAME=${digitalocean_spaces_bucket.graphics.region}
SPACES_ENDPOINT_URL=${digitalocean_spaces_bucket.graphics.endpoint}
SPACES_ACCESS_KEY_ID=${var.digitalocean_spaces_key_id}
SPACES_SECRET_KEY=${var.digitalocean_spaces_secret}
EOT
  sensitive = true
}

output "user_images_s3_env" {
  value     = <<EOT
SPACES_BUCKET_NAME=${digitalocean_spaces_bucket.user_images.name}
SPACES_REGION_NAME=${digitalocean_spaces_bucket.user_images.region}
SPACES_ENDPOINT_URL=${digitalocean_spaces_bucket.user_images.endpoint}
SPACES_ACCESS_KEY_ID=${var.digitalocean_spaces_key_id}
SPACES_SECRET_KEY=${var.digitalocean_spaces_secret}
EOT
  sensitive = true
}
