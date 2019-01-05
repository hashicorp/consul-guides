#! /bin/bash

# install the requirements
sudo chown -R ubuntu:ubuntu /home/ubuntu/.cache
pip3 install flask
pip3 install pymongo

# Product service application will be installed during init process