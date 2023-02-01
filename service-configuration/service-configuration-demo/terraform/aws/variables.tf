# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Required
variable "project_name" {
    type        = "string"
    description = "Set this, resources are given a unique name based on this"
}

variable "hashi_tags" {
    type    = "map"
    default = {
        "TTL"     = ""
        "owner"   = ""
        "project" = ""
    }
}

variable "ssh_key_name" {
  description = "Name of existing AWS ssh key"
}

# Optional

# Ingress CIDR for Vault and Consul
variable "security_group_ingress" {
  description = "Ingress CIDR to allow Vault and Consul access. Setting 0.0.0.0/0 is a bad idea as this deployment does not use TLS."
  type = "list"
  default = ["1.1.1.1/32"]
}

variable "server_machine_type" {
  description = "The machine type (size) to deploy"
  default     = "t2.micro"
}

# Images currently exist in us-east-1 and us-west-1
variable "aws_region" {
  description = "Region into which to deploy"
  default     = "us-east-1"
}

variable "client_machine_type" {
  description = "The machine type (size) to deploy"
  default     = "t2.micro"
}

variable "consul_servers_count" {
  description = "How many Consul servers to create in each region"
  default     = "3"
}

variable "client_db_count" {
  description = "The number of client machines to create in each region"
  default     = "1"
}

variable "client_product_count" {
  description = "The number of product machines to create in each region"
  default     = "2"
}

variable "client_listing_count" {
  description = "The number of listing machines to create in each region"
  default     = "2"
}

variable "client_webclient_count" {
    description = "The number of webclients to create in each region"
    default     = "2"
}
