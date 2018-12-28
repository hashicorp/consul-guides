#! /bin/bash

# Stop service if up already
systemctl stop web_client.service

# Create application directory and create a PID file:
rm -rf /home/ubuntu/src && mkdir -p /home/ubuntu/src
cd /tmp
git clone https://github.com/hashicorp/consul-guides.git
# PR only step:
cd consul-guides && git fetch && git checkout add-service-configuration && cd ..
cp -r /tmp/consul-guides/service-configuration/service-configuration-demo/application/simple-client /home/ubuntu/src
chown -R ubuntu:ubuntu /home/ubuntu/src/simple-client

# Start the service
systemctl start web_client.service
