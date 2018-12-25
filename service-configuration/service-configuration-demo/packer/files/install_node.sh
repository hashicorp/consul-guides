#! /bin/bash

# install Node
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sleep 15
sudo apt-get install -y nodejs
sleep 15

# install the listing service app
mkdir /home/ubuntu/src
cd /home/ubuntu/src
git clone https://github.com/thomashashi/listing-service.git
cd listing-service
npm install
