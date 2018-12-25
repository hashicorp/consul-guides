#! /bin/bash

echo "Unzipping Consul"
cd /tmp && sudo unzip consul.zip -d /usr/local/bin/

echo "Creating consul user and group"
sudo adduser --no-create-home --disabled-password --gecos "" consul

echo "Creating directories"
sudo mkdir -p /etc/consul/
sudo chown -R consul:consul /etc/consul/
sudo mkdir -p /opt/consul/
sudo chown -R consul:consul /opt/consul/

echo "Finished!"
