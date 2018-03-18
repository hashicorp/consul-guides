output "zREADME" {
  value = <<README
Your "${var.name}" Consul cluster has been successfully provisioned!

A private RSA key has been generated and downloaded locally. The file permissions have been changed to 0600 so the key can be used immediately for SSH or scp.

If you're not running Terraform locally (e.g. in TFE or Jenkins) but are using remote state and need the private key locally for SSH, run the below command to download.

  ${join("\n  ", formatlist("$ echo \"$(terraform output private_key_pem)\" > %s && chmod 0600 %s", split(",", module.network_aws.private_key_filename), split(",", module.network_aws.private_key_filename)))}

Run the below command to add this private key to the list maintained by ssh-agent so you're not prompted for it when using SSH or scp to connect to hosts with your public key.

  ${join("\n  ", formatlist("$ ssh-add %s", split(",", module.network_aws.private_key_filename)))}

The public part of the key loaded into the agent ("public_key_openssh" output) has been placed on the target system in ~/.ssh/authorized_keys.

To SSH into a Bastion host using this private key, run one of the below commands.

  ${join("\n  ", formatlist("$ ssh -A -i %s %s@%s", split(",", module.network_aws.private_key_filename), module.network_aws.bastion_username, module.network_aws.bastion_ips_public))}

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

To SSH into one of the Consul server nodes from the Bastion host, run the below command and it will use Consul DNS to lookup the address of one of the healthy Consul server nodes and SSH you in.

  $ ssh -A ${module.consul_aws.consul_username}@consul.service.consul

To force the generation of a new key, the private key instance can be "tainted" using the below command.

  $ terraform taint -module=network_aws.ssh_keypair_aws.tls_private_key tls_private_key.key
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

output "bastion_security_group" {
  value = "${module.network_aws.bastion_security_group}"
}

output "bastion_ips_public" {
  value = "${module.network_aws.bastion_ips_public}"
}

output "bastion_username" {
  value = "${module.network_aws.bastion_username}"
}

output "private_key_name" {
  value = "${module.network_aws.private_key_name}"
}

output "private_key_filename" {
  value = "${module.network_aws.private_key_filename}"
}

output "private_key_pem" {
  value = "${module.network_aws.private_key_pem}"
}

output "public_key_pem" {
  value = "${module.network_aws.public_key_pem}"
}

output "public_key_openssh" {
  value = "${module.network_aws.public_key_openssh}"
}

output "ssh_key_name" {
  value = "${module.network_aws.ssh_key_name}"
}

output "consul_asg_id" {
  value = "${module.consul_aws.consul_asg_id}"
}

output "consul_sg_id" {
  value = "${module.consul_aws.consul_sg_id}"
}
