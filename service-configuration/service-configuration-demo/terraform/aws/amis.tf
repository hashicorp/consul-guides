# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "aws_ami" "vault" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["*-aws-ubuntu-vault-server-*"]
    }
}

data "aws_ami" "consul" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["*-aws-ubuntu-consul-server-*"]
    }
}

data "aws_ami" "mongo-noconnect" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["*-aws-ubuntu-mongodb-noconnect-*"]
    }
}

data "aws_ami" "product-api-noconnect-consul-template" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["*-aws-ubuntu-product-consul-template-noconnect-*"]
    }
}

data "aws_ami" "listing-api-noconnect-envconsul" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["*-aws-ubuntu-listing-envconsul-noconnect-*"]
    }
}

data "aws_ami" "webclient-noconnect" {
    most_recent = true
    owners      = ["753646501470"] # hc-sc-demos-2018

    filter {
        name   = "name"
        values = ["*-webclient-configdemo-noconnect-*"]
    }
}
