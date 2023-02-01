# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Deploy a Vault Server

# Render userdata
resource "random_pet" "prefix" {}
data "template_file" "vault_startup_script" {
  template = "${file("${path.module}/init_vault.tpl")}"
  vars {
    consul_server_ip0 = "${aws_instance.consul.0.private_ip}"
    vault_path = "vault-${random_pet.prefix.id}"
    product_ami = "${data.aws_ami.product-api-noconnect-consul-template.id}"
    listing_ami = "${data.aws_ami.listing-api-noconnect-envconsul.id}"
    mongo_ami = "${data.aws_ami.mongo-noconnect.id}"
    account_id = "753646501470" # hc-sc-demos-2018
  }
}

resource aws_instance "vault" {
    ami       = "${data.aws_ami.vault.id}"
    count			= "1"
    instance_type		= "${var.client_machine_type}"
    key_name			= "${var.ssh_key_name}"
    subnet_id			= "${element(data.aws_subnet_ids.default.ids, count.index)}"
    associate_public_ip_address = true
    vpc_security_group_ids      = ["${aws_security_group.vault_server_sg.id}"]
#    iam_instance_profile        = "${aws_iam_instance_profile.consul_client_iam_profile.name}"
    iam_instance_profile        = "${aws_iam_instance_profile.vault_ec2_profile.name}"

    tags = "${merge(var.hashi_tags, map("Name", "${var.project_name}-vault-server-${count.index}"), map("role", "vault-server"), map("consul-cluster-name", replace("consul-cluster-${var.project_name}-${var.hashi_tags["owner"]}", " ", "")))}"
    user_data = "${data.template_file.vault_startup_script.rendered}"
}

output "vault_servers" {
    value = ["${aws_instance.vault.*.public_dns}"]
}

# IAM for Vault server
resource "aws_iam_role" "vault_ec2_role" {
  name = "${var.project_name}-vault-role"
  description = "Vault Server IAM Role"

  assume_role_policy = <<EOF
{ 
  "Version": "2012-10-17",
  "Statement": [
    { 
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "vault_ec2_profile" {                             
  name  = "${var.project_name}-vault-profile"                         
  role = "${aws_iam_role.vault_ec2_role.name}"
}

resource "aws_iam_policy" "vault_policy" {
  name        = "${var.project_name}-vault-policy"
  description = "policy for Vault server on AWS"
  policy      = "${file("vaultpolicy.json")}"
}

resource "aws_iam_policy_attachment" "vault-attach" {
  name       = "${var.project_name}-vault-attachment"
  roles      = ["${aws_iam_role.vault_ec2_role.name}"]
  policy_arn = "${aws_iam_policy.vault_policy.arn}"
}

# Security groups

resource aws_security_group "vault_server_sg" {
    description = "Traffic allowed to Vault servers"
    tags        = "${var.hashi_tags}"
}

resource "aws_security_group_rule" "vault_server_ingress_allow_consul_vault" {
  type              = "ingress"
  from_port         = 8200
  to_port           = 8600
  protocol          = "tcp"
  cidr_blocks       = "${var.security_group_ingress}"
  security_group_id = "${aws_security_group.vault_server_sg.id}"
}

resource aws_security_group_rule "vault_server_ssh_from_world" {
    security_group_id = "${aws_security_group.vault_server_sg.id}"
    type              = "ingress"
    protocol          = "tcp"
    from_port         = 22
    to_port           = 22
    cidr_blocks       = ["0.0.0.0/0"]
}

resource aws_security_group_rule "vault_server_allow_everything_internal" {
    security_group_id = "${aws_security_group.vault_server_sg.id}"
    type              = "ingress"
    protocol          = "all"
    from_port         = 0
    to_port           = 65535
    cidr_blocks       = ["${data.aws_vpc.default.cidr_block}"]
}

resource aws_security_group_rule "vault_server_allow_everything_out" {
    security_group_id = "${aws_security_group.vault_server_sg.id}"
    type              = "egress"
    protocol          = "all"
    from_port         = 0
    to_port           = 65535
    cidr_blocks       = ["0.0.0.0/0"]
}
