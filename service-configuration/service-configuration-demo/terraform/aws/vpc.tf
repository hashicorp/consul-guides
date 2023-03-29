# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "aws_vpc" "default" {
    default = true
}

data "aws_subnet_ids" "default" {
    vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_subnet" "default" {
    count = "${length(data.aws_subnet_ids.default.ids)}"
    id    = "${data.aws_subnet_ids.default.ids[count.index]}"
}
