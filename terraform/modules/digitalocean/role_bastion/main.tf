# ---------------------------------------------------------------------------------------------------------------------
# THESE TEMPLATES REQUIRE TERRAFORM VERSION 0.11.4 AND ABOVE
# ---------------------------------------------------------------------------------------------------------------------

terraform {
    required_version = ">= 0.11.4"
}

locals {
    # I prepend to each tag something like "TheBestProject:PRODUCTION"
    # to distinct values between different projects and stages.
    tag_prefix = "${var.project_name}:${var.stage}"
}

locals {
    droplet_tags = [
        "${var.tags}",
        "project-name:${var.project_name}",
        "stage:${var.stage}",

        "${local.tag_prefix}:snapshot:${replace(var.snapshot_name, ".", "_")}",
        "${local.tag_prefix}:role:bastion",
    ]
}

# Firewalls' tags
locals {
    fw_bastion_tag_name = "${local.tag_prefix}:role:bastion"
    fw_bastion_citizen_tag_name = "${local.tag_prefix}:role:bastion-citizen"

    # This is used only to bulk create tags.
    fw_bastion_tags = [
        "${local.fw_bastion_tag_name}",
        "${local.fw_bastion_citizen_tag_name}",
    ]
}

locals {
    // Эти таги используются в самом правиле firewall'a для предоставления
    // доступа к виртуалке по ssh.
    firewall_ssh_dest_tags = [
        "${local.tag_prefix}:role:bastion-citizen",
    ]
}

locals {
    droplet_name_prefix = "${var.stage}-${var.project_name}-bastion"
}

# ---------------------------------------------------------------------------------------------------------------------
# Droplet will be created from such snapshot
# ---------------------------------------------------------------------------------------------------------------------

data "digitalocean_image" "snapshot" {
    name = "${var.snapshot_name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# !!! This is the place where all magic with tags happens.
# ---------------------------------------------------------------------------------------------------------------------

module "droplet_tags" {
    source = "../tags"

    tags = ["${local.droplet_tags}"]
}

module "tmp_fw_bastion_tags" {
    source = "../tags"

    tags = ["${local.fw_bastion_tags}"]
}

module "firewall_ssh_dest_tags" {
    source = "../tags"

    tags = ["${local.firewall_ssh_dest_tags}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE BASTION NODES
# ---------------------------------------------------------------------------------------------------------------------

resource "digitalocean_droplet" "bastion" {
    # !!! This is very important part. Without this line Terraform raises an error.
    depends_on         = ["module.droplet_tags"]
    
    count              = "${var.num_nodes}"

    name               = "${local.droplet_name_prefix}-${count.index}"
    image              = "${data.digitalocean_image.snapshot.image}"
    region             = "${var.region}"
    size               = "${var.droplet_type}"
    backups            = false
    monitoring         = false
    ipv6               = false
    private_networking = true
    ssh_keys           = ["${split(",", var.ssh_fingerprint)}"]

    # !!! Instead of "digitalocean_tag.bastion.*.id" use the following:
    tags               = ["${module.droplet_tags.tags}"]
}

# Allow SSH access to the Bastion from the Web.
resource "digitalocean_firewall" "bastion" {
    name = "${local.droplet_name_prefix}"
    
    # !!! This is very important part. Without this line Terraform raises an error.
    depends_on = [
        "module.droplet_tags",
        "module.firewall_ssh_dest_tags",
    ]

    inbound_rule = [
        {
            protocol         = "tcp"
            port_range       = "${var.ssh_port}"
            source_addresses = ["${split(",", var.allowed_cidr_ranges)}"]
        },
    ]
    
    outbound_rule = [
        {
            protocol              = "tcp"
            port_range            = "1-65535"
            destination_addresses = ["0.0.0.0/0", "::/0"]
        },
        {
            protocol              = "udp"
            port_range            = "1-65535"
            destination_addresses = ["0.0.0.0/0", "::/0"]
        }
    ]
    tags = ["${local.tag_prefix}:role:bastion"]
}

# Allow an access to other Droplets only from the Bastion.
resource "digitalocean_firewall" "bastion_citizen" {
    name = "${local.droplet_name_prefix}-citizen"
    
    # !!! This is very important part. Without this line Terraform raises an error.
    depends_on = ["module.tmp_fw_bastion_tags"]
    
    inbound_rule = [
        {
            protocol    = "tcp"
            port_range  = "${var.ssh_port}"
            source_tags = ["${local.fw_bastion_tag_name}"]
        },
    ]
    tags = ["${local.fw_bastion_citizen_tag_name}"]
}
