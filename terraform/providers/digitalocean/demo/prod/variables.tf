# ------------------------------------------------------------------------------
# Shared variables, symlinked to each component
# ------------------------------------------------------------------------------

variable "project_name" {
    default = "TheBestProject"
}

variable "stage" {
    default = "PROD"
}

# I have bash-wrappers to run Terraform. This values defined in a "local_vars"
# file from the repo root, which then exported (so that this values are taken
# from ENV)
variable "ssh_fingerprint" {}
variable "digitalocean_api_token" {}
variable "region" {}

variable "base_droplet_tags" {
    type = "list"
    default = ["Terraform:yes", "Company:YOUR-COMPANY"]
}


#-------------------------------------------------------------------------------
# Vars for mgmt/bastion-host.
# All values might be overriden in a component via .tfvars file,
# environment variables or CLI argument "-var".
#-------------------------------------------------------------------------------

variable "mgmt_bastion-host_snapshot" {
    default = "role_bastion-ubuntu-16-04-x64-v0.0.0"
}
