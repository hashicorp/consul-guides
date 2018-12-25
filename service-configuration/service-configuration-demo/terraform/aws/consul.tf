# Deploy a Consul Cluster

resource aws_instance "consul" {
    ami                         = "${data.aws_ami.consul.id}"
    count			= "${var.consul_servers_count}"
    instance_type		= "${var.server_machine_type}"
    key_name			= "${var.ssh_key_name}"
    subnet_id			= "${element(data.aws_subnet_ids.default.ids, count.index)}"
    associate_public_ip_address = true
    vpc_security_group_ids      = ["${aws_security_group.consul_server_sg.id}"]
    iam_instance_profile        = "${aws_iam_instance_profile.consul_server_iam_profile.name}"

    tags = "${merge(var.hashi_tags, map("Name", "${var.project_name}-consul-server"), map("role", "consul-server"), map("consul-cluster-name", replace("consul-cluster-${var.project_name}-${var.hashi_tags["owner"]}", " ", "")))}"
}

output "consul_servers" {
    value = ["${aws_instance.consul.*.public_dns}"]
}

# Allow Consul Servers to call ec2:DescribeTags for Cloud AutoJoin

resource "aws_iam_instance_profile" "consul_server_iam_profile" {
    name = "${var.project_name}-consul_server_profile"
    role = "${aws_iam_role.consul_server_iam_role.name}"
}

resource "aws_iam_role" "consul_server_iam_role" {
    name        = "${var.project_name}-consul_server_role"
    description = "CC Demo Consul Server IAM Role"

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

resource "aws_iam_role_policy" "describe_tags" {
    name        = "${var.project_name}-policy-desc"
    role        = "${aws_iam_role.consul_server_iam_role.id}"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": [
            "ec2:DescribeTags"
        ],
        "Resource": "*"
    }
}
EOF
}

resource "aws_iam_role_policy" "describe_instances" {
    name = "${var.project_name}-policy-desc-instances"
    role = "${aws_iam_role.consul_server_iam_role.id}"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
	"Effect": "Allow",
	"Action": [
	    "ec2:DescribeInstances"
	],
	"Resource": "*"
    }
}
EOF
}

# Allow Consul clients also to call ec2:DescribeTags for Cloud AutoJoin

resource "aws_iam_instance_profile" "consul_client_iam_profile" {
    name = "${var.project_name}-consul_client_profile"
    role = "${aws_iam_role.consul_client_iam_role.name}"
}

resource "aws_iam_role" "consul_client_iam_role" {
    name        = "${var.project_name}-consul_client_role"
    description = "CC Demo Consul Client IAM Role"

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

resource "aws_iam_role_policy" "client_describe_tags" {
    name        = "${var.project_name}-client-policy-desc"
    role        = "${aws_iam_role.consul_client_iam_role.id}"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": [
            "ec2:DescribeTags"
        ],
        "Resource": "*"
    }
}
EOF
}

resource "aws_iam_role_policy" "client_describe_instances" {
    name = "${var.project_name}-client-policy-desc-instances"
    role = "${aws_iam_role.consul_client_iam_role.id}"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": {
	"Effect": "Allow",
	"Action": [
	    "ec2:DescribeInstances"
	],
	"Resource": "*"
    }
}
EOF
}

# Security groups

resource aws_security_group "consul_server_sg" {
    description = "Traffic allowed to Consul servers"
    tags        = "${var.hashi_tags}"
}

resource "aws_security_group_rule" "consul_server_ingress_allow_consul_vault" {
  type              = "ingress"
  from_port         = 8200
  to_port           = 8600
  protocol          = "tcp"
  cidr_blocks       = "${var.security_group_ingress}"
  security_group_id = "${aws_security_group.consul_server_sg.id}"
}

resource aws_security_group_rule "consul_server_ssh_from_world" {
    security_group_id = "${aws_security_group.consul_server_sg.id}"
    type              = "ingress"
    protocol          = "tcp"
    from_port         = 22
    to_port           = 22
    cidr_blocks       = ["0.0.0.0/0"]
}

resource aws_security_group_rule "consul_server_allow_everything_internal" {
    security_group_id = "${aws_security_group.consul_server_sg.id}"
    type              = "ingress"
    protocol          = "all"
    from_port         = 0
    to_port           = 65535
    cidr_blocks       = ["${data.aws_vpc.default.cidr_block}"]
}

resource aws_security_group_rule "consul_server_allow_everything_out" {
    security_group_id = "${aws_security_group.consul_server_sg.id}"
    type              = "egress"
    protocol          = "all"
    from_port         = 0
    to_port           = 65535
    cidr_blocks       = ["0.0.0.0/0"]
}
