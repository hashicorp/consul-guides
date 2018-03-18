output "zREADME" {
  value = <<README
Your "${var.name}" Consul cluster has been successfully provisioned!

A private RSA key has been generated and downloaded locally. The file permissions have been changed to 0600 so the key can be used immediately for SSH or scp.

If you're not running Terraform locally (e.g. in TFE or Jenkins) but are using remote state and need the private key locally for SSH, run the below command to download.

  ${join("\n  ", formatlist("$ echo \"$(terraform output private_key_pem)\" > %s && chmod 0600 %s", module.ssh_keypair_aws.private_key_filename, module.ssh_keypair_aws.private_key_filename))}

Run the below command to add this private key to the list maintained by ssh-agent so you're not prompted for it when using SSH or scp to connect to hosts with your public key.

  ${join("\n  ", formatlist("$ ssh-add %s", module.ssh_keypair_aws.private_key_filename))}

The public part of the key loaded into the agent ("public_key_openssh" output) has been placed on the target system in ~/.ssh/authorized_keys.

To SSH into a Consul host using this private key, run the below command after replacing "HOST" with the public IP of one of the provisioned Consul hosts.

  ${join("\n  ", formatlist("$ ssh -A -i %s %s@HOST", module.ssh_keypair_aws.private_key_filename, module.consul_aws.consul_username))}

You can now interact with Consul using any of the CLI (https://www.consul.io/docs/commands/index.html) or API (https://www.consul.io/api/index.html) commands.

  # Use the CLI to retrieve the Consul members, write a key/value, and read that key/value
  $ consul members
  $ consul kv put cli bar=baz
  $ consul kv get cli

  # Use the API to retrieve the Consul members, write a key/value, and read that key/value
  $ curl \
    http://127.0.0.1:8500/v1/agent/members | jq '.'
  $ curl \
      -X PUT \
      -d '{"bar=baz"}' \
      http://127.0.0.1:8500/v1/kv/api | jq '.'
  $ curl \
      http://127.0.0.1:8500/v1/kv/api | jq '.'

Because this is a development environment, the Consul nodes are in a public subnet with SSH access open from the outside. WARNING - DO NOT DO THIS IN PRODUCTION!
README
}

output "vpc_cidr_block" {
  value = "${module.network_aws.vpc_cidr_block}"
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
