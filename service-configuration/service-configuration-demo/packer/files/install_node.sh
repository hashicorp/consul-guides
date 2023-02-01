#! /bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


# install Node
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sleep 15
sudo apt-get install -y nodejs
sleep 15

# Listing service application will be installed during init process