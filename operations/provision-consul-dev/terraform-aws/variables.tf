variable "name"              { }
variable "vpc_cidrs_public"  { type = "list" }
variable "nat_count"         { }
variable "bastion_count"     { }
variable "consul_public_ip"  { }
variable "consul_count"      { }
variable "ami_owner"         { default = "309956199498" } # Base RHEL owner
variable "ami_name"          { default = "*RHEL-7.3_HVM_GA-*" } # Base RHEL name
variable "consul_version"    { default = "1.0.1" }
variable "consul_url"        { default = "" }
variable "consul_image_id"   { default = "" }

variable "network_tags" {
  type    = "map"
  default = { }
}

variable "consul_tags" {
  type    = "list"
  default = [ ]
}
