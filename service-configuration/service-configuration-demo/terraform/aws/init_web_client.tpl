#! /bin/bash

# Stop service if up already
systemctl stop web_client.service

# Create application directory and create a PID file:
cd /home/ubuntu/src
rm -rf simple-client
git clone https://github.com/kawsark/simple-client.git
chown -R ubuntu:ubuntu simple-client

# Start the service
systemctl start web_client.service
