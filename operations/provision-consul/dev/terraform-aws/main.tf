# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

module "ssh_keypair_aws" {
  source = "github.com/hashicorp-modules/ssh-keypair-aws"
}

data "aws_ami" "base" {
  most_recent = true
  owners      = ["${var.ami_owner}"]

  filter {
    name   = "name"
    values = ["${var.ami_name}"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "base_install" {
  template = "${file("${path.module}/../../templates/install-base.sh.tpl")}"
}

data "template_file" "consul_install" {
  template = "${file("${path.module}/../../templates/install-consul-systemd.sh.tpl")}"

  vars = {
    consul_version  = "${var.consul_version}"
    consul_url      = "${var.consul_url}"
    name            = "${var.name}"
    local_ip_url    = "${var.local_ip_url}"
    consul_override = "${var.consul_config_override != "" ? true : false}"
    consul_config   = "${var.consul_config_override}"
  }
}

module "network_aws" {
  source = "github.com/hashicorp-modules/network-aws"

  name              = "${var.name}"
  vpc_cidr          = "${var.vpc_cidr}"
  vpc_cidrs_public  = "${var.vpc_cidrs_public}"
  nat_count         = "${var.nat_count}"
  vpc_cidrs_private = "${var.vpc_cidrs_private}"
  bastion_count     = "${var.bastion_servers}"
  image_id          = "${var.bastion_image_id != "" ? var.bastion_image_id : data.aws_ami.base.id}"
  private_key_file  = "${module.ssh_keypair_aws.private_key_filename}"
  tags              = "${var.network_tags}"
}

module "consul_aws" {
  source = "github.com/hashicorp-modules/consul-aws"

  name          = "${var.name}" # Must match network_aws module name for Consul Auto Join to work
  vpc_id        = "${module.network_aws.vpc_id}"
  vpc_cidr      = "${module.network_aws.vpc_cidr}"
  subnet_ids    = "${split(",", var.consul_public ? join(",", module.network_aws.subnet_public_ids) : join(",", module.network_aws.subnet_private_ids))}"
  count         = "${var.consul_servers}"
  instance_type = "${var.consul_instance}"
  image_id      = "${var.consul_image_id != "" ? var.consul_image_id : data.aws_ami.base.id}"
  public        = "${var.consul_public}"
  ssh_key_name  = "${module.ssh_keypair_aws.name}"
  tags          = "${var.consul_tags}"
  tags_list     = "${var.consul_tags_list}"

  user_data = <<EOF
${data.template_file.base_install.rendered} # Runtime install base tools
${data.template_file.consul_install.rendered} # Runtime install Consul in -dev mode
EOF
}
