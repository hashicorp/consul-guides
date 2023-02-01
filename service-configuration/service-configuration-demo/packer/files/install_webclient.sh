#! /bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


# install the requirements
sudo chown -R ubuntu:ubuntu /home/ubuntu/
pip3 install flask
pip3 install pymongo

# Create application directory and create a PID file:
rm -rf /home/ubuntu/src && mkdir -p /home/ubuntu/src
cd /tmp
git clone https://github.com/hashicorp/consul-guides.git
cp -r /tmp/consul-guides/service-configuration/service-configuration-demo/application/simple-client /home/ubuntu/src
chown -R ubuntu:ubuntu /home/ubuntu/src/simple-client
