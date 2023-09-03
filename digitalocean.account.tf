variable "digitalocean_ssh_key_name" {
  type        = string
  description = "Name of the SSH key on your machine used to access DigitalOcean droplets"
  default     = "digitalocean-golden-vcr"
}

resource "digitalocean_ssh_key" "default" {
  name       = var.digitalocean_ssh_key_name
  public_key = file(pathexpand("~/.ssh/${var.digitalocean_ssh_key_name}.pub"))
}
