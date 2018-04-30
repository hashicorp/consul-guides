output "zREADME" {
  value = <<README

Your "${var.name}" AWS Consul dev cluster has been
successfully provisioned!

${module.network_aws.zREADME}To force the generation of a new key, the private key instance can be
"tainted" using the below command.

  $ terraform taint -module=ssh_keypair_aws.tls_private_key \
      tls_private_key.key

# ------------------------------------------------------------------------------
# Local HTTP API Requests
# ------------------------------------------------------------------------------

If you're making HTTP API requests outside the Bastion (locally), set
the below env vars.

The `consul_public` variable must be set to true for requests to work.

`consul_public`: ${var.consul_public}

  ${format("$ export CONSUL_ADDR=http://%s:8500", module.consul_aws.consul_lb_dns)}

# ------------------------------------------------------------------------------
# Consul Dev
# ------------------------------------------------------------------------------

${format("Consul UI: http://%s %s", module.consul_aws.consul_lb_dns, var.consul_public ? "(Public)" : "(Internal)")}

You can SSH into the Consul node by updating the "PUBLIC_IP" and running the
below command.

  $ ${format("ssh -A -i %s %s@%s", module.ssh_keypair_aws.private_key_filename, module.consul_aws.consul_username, "PUBLIC_IP")}

${module.consul_aws.zREADME}
README
}

output "vpc_cidr" {
  value = "${module.network_aws.vpc_cidr}"
}

output "vpc_id" {
  value = "${module.network_aws.vpc_id}"
}

output "subnet_public_ids" {
  value = "${module.network_aws.subnet_public_ids}"
}

output "subnet_private_ids" {
  value = "${module.network_aws.subnet_private_ids}"
}

output "private_key_name" {
  value = "${module.ssh_keypair_aws.private_key_name}"
}

output "private_key_filename" {
  value = "${module.ssh_keypair_aws.private_key_filename}"
}

output "private_key_pem" {
  value = "${module.ssh_keypair_aws.private_key_pem}"
}

output "public_key_pem" {
  value = "${module.ssh_keypair_aws.public_key_pem}"
}

output "public_key_openssh" {
  value = "${module.ssh_keypair_aws.public_key_openssh}"
}

output "ssh_key_name" {
  value = "${module.ssh_keypair_aws.name}"
}

output "consul_asg_id" {
  value = "${module.consul_aws.consul_asg_id}"
}

output "consul_sg_id" {
  value = "${module.consul_aws.consul_sg_id}"
}

output "consul_lb_sg_id" {
  value = "${module.consul_aws.consul_lb_sg_id}"
}

output "consul_tg_http_8500_arn" {
  value = "${module.consul_aws.consul_tg_http_8500_arn}"
}

output "consul_lb_dns" {
  value = "${module.consul_aws.consul_lb_dns}"
}
