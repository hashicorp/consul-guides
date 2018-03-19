name             = "consul-dev"
vpc_cidrs_public = ["10.139.1.0/24",]
nat_count        = "1"
bastion_count    = "0"
consul_public_ip = "true"
consul_count     = "1"
# ami_owner        = "099720109477" # Base image owner, defaults to RHEL
# ami_name         = "*ubuntu-xenial-16.04-amd64-server-*" # Base image name, defaults to RHEL
# consul_version   = "1.0.1" # Consul Version for runtime install, defaults to 1.0.1
# consul_url       = "" # Consul Enterprise download URL for runtime install, defaults to Consul OSS
# consul_image_id  = "" # AMI ID override, defaults to base RHEL AMI

# Example tags
# network_tags = {"owner" = "hashicorp", "TTL" = "24"}

# consul_tags = [
#   {"key" = "owner", "value" = "hashicorp", "propagate_at_launch" = true},
#   {"key" = "TTL", "value" = "24", "propagate_at_launch" = true}
# ]
