module "ssh_keypair_aws" {
  source = "git@github.com:hashicorp-modules/ssh-keypair-aws.git?ref=f-refactor"
}

module "network_aws" {
  source = "git@github.com:hashicorp-modules/network-aws.git?ref=f-refactor"

  name              = "${var.name}"
  vpc_cidrs_public  = "${var.vpc_cidrs_public}"
  nat_count         = "${var.nat_count}"
  vpc_cidrs_private = "${var.vpc_cidrs_private}"
  bastion_count     = "${var.bastion_count}"
  ssh_key_name      = "${module.ssh_keypair_aws.name}"
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

data "template_file" "consul_install_user_data" {
  template = "${file("${path.module}/../../templates/consul-install-systemd.sh.tpl")}"

  vars = {
    group   = "${var.group}"
    user    = "${var.user}"
    comment = "${var.comment}"
    home    = "${var.home}"
    version = "${var.version}"
    url     = "${var.url}"
  }
}

module "consul_aws" {
  source = "git@github.com:hashicorp-modules/consul-aws.git?ref=f-refactor"

  name         = "${var.name}" # Must match network_aws module name for Consul Auto Join to work
  vpc_id       = "${module.network_aws.vpc_id}"
  vpc_cidr     = "${module.network_aws.vpc_cidr_block}"
  subnet_ids   = "${module.network_aws.subnet_public_ids}" # Provision into public subnets to provide easier accessibility without a Bastion host
  os           = "${var.os}"
  public_ip    = "${var.consul_public_ip}"
  count        = "${var.consul_count}"
  image_id     = "${var.image_id != "" ? var.image_id : data.aws_ami.base.id}"
  user_data    = "${data.template_file.consul_install_user_data.rendered}" # Custom user_data
  ssh_key_name = "${module.ssh_keypair_aws.name}"
}
