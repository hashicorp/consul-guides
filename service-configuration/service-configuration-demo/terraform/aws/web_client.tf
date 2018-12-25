# Deploy a Webclient server

resource aws_instance "webclient" {
    ami                         = "${var.mode == "connect" ? data.aws_ami.webclient-connect.id : data.aws_ami.webclient-noconnect.id}"
    count			= "${var.client_webclient_count}"
    instance_type		= "${var.client_machine_type}"
    key_name			= "${var.ssh_key_name}"
    subnet_id			= "${element(data.aws_subnet_ids.default.ids, count.index)}" 
    associate_public_ip_address = true
    vpc_security_group_ids      = ["${aws_security_group.webclient_sg.id}"]
    iam_instance_profile        = "${aws_iam_instance_profile.consul_client_iam_profile.name}"
    
    tags = "${merge(var.hashi_tags, map("Name", "${var.project_name}-webclient-server-${count.index}"), map("role", "webclient-server"), map("consul-cluster-name", replace("consul-cluster-${var.project_name}-${var.hashi_tags["owner"]}", " ", "")))}"
    user_data = "${file("${path.module}/init_web_client.tpl")}"
}

output "webclient_servers" {
    value = ["${aws_instance.webclient.*.public_dns}"]
}

resource "aws_lb" "webclient-lb" {
    name               = "${var.project_name}-lb"
    internal           = false
    load_balancer_type = "application"
    subnets            = ["${data.aws_subnet_ids.default.ids}"]
    security_groups    = ["${aws_security_group.lb_sg.id}"]

    tags = "${merge(var.hashi_tags, map("Name", "${var.project_name}-lb"))}"
}

resource "aws_lb_target_group" "webclient" {
    name     = "${var.project_name}-lb-tg"
    port     = 8080
    protocol = "HTTP"
    vpc_id   = "${data.aws_vpc.default.id}"

    stickiness = {
	type    = "lb_cookie"
	enabled = false
    }
}

resource "aws_lb_target_group_attachment" "webclient" {
    count            = "${var.client_webclient_count}"
    target_group_arn = "${aws_lb_target_group.webclient.arn}"
    target_id        = "${element(aws_instance.webclient.*.id, count.index)}"

}

resource "aws_lb_listener" "webclient-lb" {
    load_balancer_arn = "${aws_lb.webclient-lb.arn}"
    port              = 80
    protocol          = "HTTP"

    default_action = {
	target_group_arn = "${aws_lb_target_group.webclient.arn}"
	type             = "forward"
    }
}

output "webclient-lb" {
    value = "${aws_lb.webclient-lb.dns_name}"
}

# Security groups for LB

resource aws_security_group "lb_sg" {
    description = "Traffic allowed to Webclient LB"
    tags        = "${var.hashi_tags}"
}

resource aws_security_group_rule "lb_80_from_world" {
    security_group_id = "${aws_security_group.lb_sg.id}"
    type              = "ingress"
    protocol          = "tcp"
    from_port         = 80
    to_port           = 80
    cidr_blocks       = ["0.0.0.0/0"]
}

resource aws_security_group_rule "lb_everything_in_internal" {
    security_group_id = "${aws_security_group.lb_sg.id}"
    type              = "ingress"
    protocol          = "all"
    from_port         = 0
    to_port           = 65535
    cidr_blocks       = ["${data.aws_vpc.default.cidr_block}"]
}

resource aws_security_group_rule "lb_everything_out" {
    security_group_id = "${aws_security_group.lb_sg.id}"
    type              = "egress"
    protocol          = "all"
    from_port         = 0
    to_port           = 65535
    cidr_blocks       = ["0.0.0.0/0"]
}

# Security groups for EC2 Instances

resource aws_security_group "webclient_sg" {
    description = "Traffic allowed to Webclient servers"
    tags        = "${var.hashi_tags}"
}

resource aws_security_group_rule "webclient_ssh_from_world" {
    security_group_id = "${aws_security_group.webclient_sg.id}"
    type              = "ingress"
    protocol          = "tcp"
    from_port         = 22
    to_port           = 22
    cidr_blocks       = ["0.0.0.0/0"]
}

resource aws_security_group_rule "webclient_allow_everything_internal" {
    security_group_id = "${aws_security_group.webclient_sg.id}"
    type              = "ingress"
    protocol          = "all"
    from_port         = 0
    to_port           = 65535
    cidr_blocks       = ["${data.aws_vpc.default.cidr_block}"]
}

resource aws_security_group_rule "webclient_allow_everything_out" {
    security_group_id = "${aws_security_group.webclient_sg.id}"
    type              = "egress"
    protocol          = "all"
    from_port         = 0
    to_port           = 65535
    cidr_blocks       = ["0.0.0.0/0"]
}
