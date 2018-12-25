#! /bin/bash

# install mongodb
echo "### apt-key adv"
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
sleep 5
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
sleep 5
echo "### apt-get update"
sudo apt-get update
sleep 5
sudo apt-get install -y -qq mongodb-org 
sleep 5

sudo systemctl enable mongod
sudo systemctl start mongod

sleep 10

# seed some initial records
cat <<EOF >> /tmp/m.js
use bbthe90s
db.products.insertMany([ { 'inv_id': 1, 'name':'inv_1', 'cost':35.57, 'img':null}, { 'inv_id': 2, 'name':'inv_2', 'cost':22.50, 'img':null}, { 'inv_id': 3, 'name':'inv_3', 'cost':12.37, 'img':null}, { 'inv_id': 4, 'name':'inv_4', 'cost':17.95, 'img':null}])
db.listings.insertMany([ { 'listing_id': 1, 'name':'listing_1', 'reserve':12.95, current_bid: 23.43, 'img':null}, { 'listing_id': 2, 'name':'listing_2', 'reserve':35.57, current_bid: 23.43, 'img':null}, { 'listing_id': 3, 'name':'garden gnome', 'reserve':35.57, current_bid: 23.43, 'img':null}, { 'listing_id': 4, 'name':'listing_4', 'reserve':35.57, current_bid: 23.43, 'img':null}])
EOF

mongo < /tmp/m.js
