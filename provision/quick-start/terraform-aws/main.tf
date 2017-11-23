data "template_file" "bastion_user_data" {
  template = "${file("${path.module}/../../templates/bastion-init-systemd.sh.tpl")}"

  vars = {
    name     = "${var.name}"
    provider = "aws"
  }
}

module "network_aws" {
  source = "git@github.com:hashicorp-modules/network-aws.git?ref=f-refactor"

  name          = "${var.name}"
  nat_count     = "1"
  bastion_count = "1"
  user_data     = "${data.template_file.bastion_user_data.rendered}" # Override user_data
}

data "template_file" "consul_user_data" {
  template = "${file("${path.module}/../../templates/consul-init-systemd.sh.tpl")}"

  vars = {
    name             = "${var.name}"
    bootstrap_expect = "${length(module.network_aws.subnet_private_ids)}"
    provider         = "aws"
  }
}

module "consul_aws" {
  source = "git@github.com:hashicorp-modules/consul-aws.git?ref=f-refactor"

  name         = "${var.name}" # Must match network_aws module name for Consul Auto Join to work
  vpc_id       = "${module.network_aws.vpc_id}"
  vpc_cidr     = "${module.network_aws.vpc_cidr_block}"
  subnet_ids   = "${module.network_aws.subnet_private_ids}"
  user_data    = "${data.template_file.consul_user_data.rendered}" # Custom user_data
  ssh_key_name = "${module.network_aws.ssh_key_name}"
}
