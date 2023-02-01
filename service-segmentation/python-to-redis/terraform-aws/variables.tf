# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "ami_id" {
  description = "ID of the AMI to provision. Default is Ubuntu 16.04 Base Image in us-east-2"
  default     = "ami-0552e3455b9bc8d50"
}

variable "owner" {
  description = "An Owner tag"
  default = "demo-user"
}

variable "aws_region" {
  description = "The AWS region this infrastructure should be provisioned in"
  default = "us-east-2"
}

variable "instance_size"{
  default = "t2.micro"
}

variable "environment" {
  default = "demo"
}

variable "App" {
  default = "consul-connect-demo"
}

variable "ttl" {
  description = "A desired time to live (not enforced via terraform)"
  default = "24"
}

