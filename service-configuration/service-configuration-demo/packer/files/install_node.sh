#! /bin/bash

# install Node
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sleep 15
sudo apt-get install -y nodejs
sleep 15

# Listing service application will be installed during init process