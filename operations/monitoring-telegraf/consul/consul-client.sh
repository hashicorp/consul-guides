#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


export DEBIAN_FRONTEND=noninteractive

apt-get -y install gawk chrony

ipaddr=$(ip addr show dev eth1 | awk 'match($0, /inet ([0-9.]*)\/24/, m) { print m[1] }')

if [ "$ipaddr" == "" ]; then
  echo "Could not find eth1 for IP address" && exit 1
fi

#
# Install Consul agent
#

cd /tmp
apt-get -y install unzip
curl -sf -o /tmp/consul.zip https://releases.hashicorp.com/consul/1.1.0/consul_1.1.0_linux_amd64.zip
unzip -o /tmp/consul*.zip -d /tmp
install -c -m 0755 /tmp/consul /usr/local/sbin
install -c -m 0644 /vagrant/consul/consul.service /etc/systemd/system
install -d -m 0755 -o vagrant /data/consul /etc/consul.d
sed -e "s/@@BIND_ADDR@@/${ipaddr}/" < /vagrant/consul/client.json.tmpl > /etc/consul.d/client.json

systemctl daemon-reload
systemctl enable consul
systemctl restart consul
