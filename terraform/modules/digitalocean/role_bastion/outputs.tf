output "public_ipv4_addresses" {
  description = "IP addresses of the bastion instance"
  value = ["${digitalocean_droplet.bastion.*.ipv4_address}"]
}