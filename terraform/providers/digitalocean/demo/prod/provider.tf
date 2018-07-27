# ------------------------------------------------------------------------------
# Provider difinition. Symlinked to each component
# ------------------------------------------------------------------------------

provider "digitalocean" {
    token = "${var.digitalocean_api_token}"
}