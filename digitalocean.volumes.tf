resource "digitalocean_volume" "db" {
  name                    = "golden-vcr-db"
  description             = "Persistent storage for the Golden VCR postgres database"
  region                  = "nyc3"
  size                    = 10
  initial_filesystem_type = "ext4"
}
