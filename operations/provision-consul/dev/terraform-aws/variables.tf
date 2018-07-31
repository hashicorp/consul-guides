# ---------------------------------------------------------------------------------------------------------------------
# General Variables
# ---------------------------------------------------------------------------------------------------------------------
variable "create"       { default = true }
variable "name"         { default = "consul-dev" }
variable "ami_owner"    { default = "309956199498" } # Base RHEL owner
variable "ami_name"     { default = "*RHEL-7.3_HVM_GA-*" } # Base RHEL name
variable "local_ip_url" { default = "http://169.254.169.254/latest/meta-data/local-ipv4" }
variable "override"     { default = "@#%*-_=+[]{}:?"}

# ---------------------------------------------------------------------------------------------------------------------
# Network Variables
# ---------------------------------------------------------------------------------------------------------------------
variable "vpc_cidr" { default = "10.139.0.0/16" }

variable "vpc_cidrs_public" {
  type    = "list"
  default = ["10.139.1.0/24", "10.139.2.0/24",]
}

variable "vpc_cidrs_private" {
  type    = "list"
  default = ["10.139.11.0/24", "10.139.12.0/24",]
}

variable "nat_count"        { default = 1 }
variable "bastion_servers"  { default = 0 }
variable "bastion_image_id" { default = "" }

variable "network_tags" {
  type    = "map"
  default = {}
}

# ---------------------------------------------------------------------------------------------------------------------
# Consul Variables
# ---------------------------------------------------------------------------------------------------------------------
variable "consul_servers"  { default = 1 }
variable "consul_instance" { default = "t2.micro" }
variable "consul_version"  { default = "1.2.0" }
variable "consul_url"      { default = "" }
variable "consul_image_id" { default = "" }

variable "consul_public" {
  description = "Assign a public IP, open port 22 for public access, & provision into public subnets to provide easier accessibility without a Bastion host - DO NOT DO THIS IN PROD"
  default     = true
}

variable "public_cidrs" {
  description = "Optional list of public cidrs to set on resources when the \"consul_public\" variable is `true`, defaults to the local workstation IP."
  type        = "list"
  default     = []
}

variable "consul_config_override" { default = "" }

variable "consul_tags" {
  type    = "map"
  default = {}
}

variable "consul_tags_list" {
  type    = "list"
  default = []
}
