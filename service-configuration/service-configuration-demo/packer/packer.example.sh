#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


# Note: please export AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY, or AWS_ACCESS_KEY and AWS_SECRET_KEY prior to executing this script. Please do not place your credentials in this file

# Setup region
export AWS_REGION=us-east-1

# DC_NAME is optional; it is prepended to all AMIs created. E.g. east, west, dc1 etc. 
# Terraform will pick the most recent AMI(s) in that region regardless of how DC_NAME is set
export DC_NAME=east

# Consul base image
packer build consul_base.json

# Consul client image
packer build consul_client.json

# Consul server image
packer build consul_server.json

# Vault server
packer build vault_server.json

# MongoDB server
packer build client_mongodb_noconnect.json

# Listing API image
packer build client_listing_noconnect_envconsul.json

# Product API image
packer build client_product_noconnect_consul-template.json

# Web Client image
packer build client_webclient_noconnect.json
