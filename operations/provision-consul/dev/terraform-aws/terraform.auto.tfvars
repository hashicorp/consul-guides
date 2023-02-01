# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# ---------------------------------------------------------------------------------------------------------------------
# General Variables
# ---------------------------------------------------------------------------------------------------------------------
# name      = "consul-dev"
# ami_owner = "099720109477" # Base image owner, defaults to RHEL
# ami_name  = "*ubuntu-xenial-16.04-amd64-server-*" # Base image name, defaults to RHEL

# ---------------------------------------------------------------------------------------------------------------------
# Network Variables
# ---------------------------------------------------------------------------------------------------------------------
# vpc_cidr          = "172.19.0.0/16"
# vpc_cidrs_public  = ["172.19.0.0/20", "172.19.16.0/20", "172.19.32.0/20",]
# vpc_cidrs_private = ["172.19.48.0/20", "172.19.64.0/20", "172.19.80.0/20",]

# nat_count        = 1 # Defaults to 1
# bastion_servers  = 0 # Defaults to 0
# bastion_image_id = "" # AMI ID override, defaults to base RHEL AMI

# network_tags = {"owner" = "hashicorp", "TTL" = "24"}

# ---------------------------------------------------------------------------------------------------------------------
# Consul Variables
# ---------------------------------------------------------------------------------------------------------------------
# consul_servers  = 3
# consul_instance = "t2.micro"
# consul_version  = "1.2.3" # Consul Version for runtime install, defaults to 1.2.3
# consul_url      = "" # Consul Enterprise download URL for runtime install, defaults to Consul OSS
# consul_image_id = "" # AMI ID override, defaults to base RHEL AMI

# If 'consul_public' is true, assign a public IP, open port 22 for public access, & provision into public subnets
# to provide easier accessibility without a Bastion host - DO NOT DO THIS IN PROD
# consul_public = false

# consul_config_override = <<EOF
# {
#   "log_level": "DEBUG",
#   "disable_remote_exec": false
# }
# EOF

# consul_tags = {"owner" = "hashicorp", "TTL" = "24"}
#
# consul_tags_list = [
#   {"key" = "owner", "value" = "hashicorp", "propagate_at_launch" = true},
#   {"key" = "TTL", "value" = "24", "propagate_at_launch" = true}
# ]
