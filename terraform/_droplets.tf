# locals {
#   droplet_names = {
#     droplet1 = "test-droplet-1"
#     droplet2 = "test-droplet-2"
#     droplet3 = "test-droplet-3"
#   }

#   my_ip = jsondecode(data.http.my_ip.response_body).ip
# }

# # Import existing SSH keys to DigitalOcean
# resource "digitalocean_ssh_key" "default" {
#   name       = "my_ssh_key"
#   public_key = file("~/.ssh/id_rsa.pub")
# }

# # Create a VPC for the droplets
# resource "digitalocean_vpc" "test_vpc" {
#   name     = "test-vpc"
#   region   = "nyc3"
#   ip_range = "10.0.0.0/16"
# }

# # Create a firewall to allow SSH and HTTP access
# resource "digitalocean_firewall" "test_firewall" {
#   name = "test-firewall"

#   droplet_ids = [
#     for droplet in digitalocean_droplet.test_droplet : droplet.id
#   ]

#   # Allow SSH from my IP
#   inbound_rule {
#     protocol         = "tcp"
#     port_range       = "22"
#     source_addresses = [local.my_ip]
#   }

#   # Allow all inbound traffic from within the VPC
#   inbound_rule {
#     protocol           = "tcp"
#     port_range         = "all"
#     source_droplet_ids = [for droplet in digitalocean_droplet.test_droplet : droplet.id]
#   }

#   # Allow all outbound traffic from anywhere
#   outbound_rule {
#     protocol              = "tcp"
#     port_range            = "all"
#     destination_addresses = ["0.0.0.0/0"]
#   }
# }

# # Three droplets for testing purposes
# resource "digitalocean_droplet" "test_droplet" {
#   for_each = local.droplet_names

#   name     = each.value
#   image    = "almalinux-10-x64"
#   region   = "nyc3"
#   size     = "s-1vcpu-1gb"
#   ssh_keys = [digitalocean_ssh_key.default.fingerprint]
#   vpc_uuid = digitalocean_vpc.test_vpc.id

#   tags = ["test"]
# }
