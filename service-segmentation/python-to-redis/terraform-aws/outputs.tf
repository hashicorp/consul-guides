# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "node_1_public_dns" {
    value = "${aws_instance.consul-n1-clientms.public_dns}"
}

output "node_2_public_dns" {
    value = "${aws_instance.consul-n2-redis-server.public_dns}"
}

output "consul_ui_url" {
    value = "http://${aws_instance.consul-n1-clientms.public_dns}:8500/ui/"
}

output "clientms_url" {
    value = "http://${aws_instance.consul-n1-clientms.public_dns}:5000/"
}

output "ssh_private_key" {
   sensitive = true
   value = "${tls_private_key.ssh_key_pair.private_key_pem}"
}