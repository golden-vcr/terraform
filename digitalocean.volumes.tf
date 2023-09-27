resource "digitalocean_volume" "data" {
  name                    = "gvcr-data"
  description             = "Persistent storage for the Golden VCR backend"
  region                  = "nyc3"
  size                    = 10
  initial_filesystem_type = "ext4"
}
