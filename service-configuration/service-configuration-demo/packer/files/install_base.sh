#! /bin/bash

echo "Updating and installing required software..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq upgrade > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq unzip wget jq python3-pip > /dev/null

cat <<EOF | sudo tee /lib/systemd/system/consul_enable_acl.service
[Unit]
Description = Enable ACL system for consul agent
Requires=consul.service
After=consul.service

[Service]
Type=oneshot
ExecStart=/etc/consul/enable_acl.sh

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl disable consul_enable_acl.service

echo "Finished!"

