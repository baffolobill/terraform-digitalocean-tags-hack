# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "region" {}
variable "digitalocean_api_token" {}
variable "ssh_fingerprint" {}
variable "project_name" {}
variable "stage" {}
variable "snapshot_name" {}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "num_nodes" {
  // How much Droplets to create
  default = 1
}

variable "droplet_type" {
  // What kind of instance type to use for the control droplet
  default = "s-1vcpu-1gb"
}

variable "tags" {
  // Extra tags
  type        = "list"
  default     = []
}

variable "allowed_cidr_ranges" {
  // Comma separated list of allowed network ranges
  default     = "0.0.0.0/0"
}

variable "ssh_port" {
  // SSH port for a firewall rule
  // Ensure, that this port is in the SSH-server config file
  default     = 22
}
