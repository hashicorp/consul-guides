#! /bin/bash

# install the requirements
sudo chown -R ubuntu:ubuntu /home/ubuntu/
pip3 install flask
pip3 install pymongo

# download the apply
mkdir /home/ubuntu/src
cd /home/ubuntu/src
git clone https://github.com/thomashashi/simple-client.git
