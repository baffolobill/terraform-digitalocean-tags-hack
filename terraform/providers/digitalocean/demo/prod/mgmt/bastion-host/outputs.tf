output "public_ipv4_addresses" {
    value = ["${module.role_bastion.public_ipv4_addresses}"]
}
