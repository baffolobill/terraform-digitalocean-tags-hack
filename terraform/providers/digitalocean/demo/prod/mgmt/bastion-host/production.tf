module "role_bastion" {
    // Use this while develop
    source = "../../../../../../modules/digitalocean/role_bastion"
    // and this - for production
    // source = "git@github.com:baffolobill/terraform-digitalocean-tags-hack.git//terraform/modules/digitalocean/role_bastion?ref=master"

    snapshot_name = "${var.mgmt_bastion-host_snapshot}"

    // common
    project_name                    = "${var.project_name}"
    stage                           = "${var.stage}"
    ssh_fingerprint                 = "${var.ssh_fingerprint}"
    region                          = "${var.region}"
    digitalocean_api_token          = "${var.digitalocean_api_token}"

    // This tags will be added to created Droplet.
    tags = ["${var.base_droplet_tags}"]
}
