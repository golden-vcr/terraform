resource "digitalocean_droplet" "api" {
  name     = "api"
  image    = "ubuntu-22-04-x64"
  region   = "nyc3"
  size     = "s-1vcpu-1gb"
  ssh_keys = [digitalocean_ssh_key.default.id]
}

resource "digitalocean_volume_attachment" "data_on_api" {
  droplet_id = digitalocean_droplet.api.id
  volume_id  = digitalocean_volume.data.id
}

output "server_ip_address" {
  value = digitalocean_droplet.api.ipv4_address
}

resource "digitalocean_droplet" "rabbitmq_server" {
  name     = "rabbitmq"
  image    = "ubuntu-22-04-x64"
  region   = "nyc3"
  size     = "s-1vcpu-1gb"
  ssh_keys = [digitalocean_ssh_key.default.id]
}

output "rabbitmq_server_ip_address" {
  value = digitalocean_droplet.rabbitmq_server.ipv4_address
}
