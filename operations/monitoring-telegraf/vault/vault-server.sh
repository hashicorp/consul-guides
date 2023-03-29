#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


export DEBIAN_FRONTEND=noninteractive

#
# Install telegraf
#

curl -sL https://repos.influxdata.com/influxdb.key | apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
apt-get update && apt-get -y install telegraf
install -c -m 0644 /vagrant/vault/telegraf.conf /etc/telegraf
systemctl enable telegraf
systemctl restart telegraf

#
# Install Vault server
#

cd /tmp
apt-get -y install unzip
curl -sf -o /tmp/vault.zip https://releases.hashicorp.com/vault/0.10.2/vault_0.10.2_linux_amd64.zip
unzip -o /tmp/vault*.zip -d /tmp
install -c -m 0755 /tmp/vault /usr/local/sbin
install -c -m 0644 /vagrant/vault/vault.service /etc/systemd/system
install -d -m 0755 -o vagrant /data/vault /etc/vault.d
install -c -m 0644 /vagrant/vault/vault_server.hcl /etc/vault.d

systemctl daemon-reload
systemctl enable vault
systemctl restart vault
