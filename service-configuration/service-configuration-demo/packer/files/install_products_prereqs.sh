#! /bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


# install the requirements
sudo chown -R ubuntu:ubuntu /home/ubuntu/.cache
pip3 install flask
pip3 install pymongo

# Product service application will be installed during init process