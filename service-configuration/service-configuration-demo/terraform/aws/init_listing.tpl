#! /bin/bash
cd /tmp

# Stop listing service if up already
systemctl stop listing.service

# Download application
cd /tmp
git clone https://github.com/kawsark/thomas_cc_demo.git
cp -r /tmp/thomas_cc_demo/application/listing-service /opt

# Create application directory and create a PID file:
cd /opt
chmod a+x /opt/listing-service/listing_wrapper.sh
cd listing-service
npm install
npm install node-vault
chown -R ubuntu:ubuntu /opt/listing-service
touch /tmp/listing-service.pid
chown -R ubuntu:ubuntu /tmp

# Delay to ensure Consul agent is available
sleep 30

# Add Listing App specific configuration:
consul kv put listing/config/version 1.0
consul kv put listing/config/DB_URL mongodb.service.consul
consul kv put listing/config/DB_PORT 27017
consul kv put listing/config/DB_NAME bbthe90s
consul kv put listing/config/DB_COLLECTION listings
consul kv put listing/config/LISTING_PORT 8000
consul kv put listing/config/LISTING_ADDR 0.0.0.0

# Adjust listing.service file with VAULT_TOKEN

# Perform AWS Auth:
export nonce=$(date +%s%N | md5sum | awk '{print $1}')
export VAULT_ADDR=http://active.vault.service.consul:8200
vault write auth/aws/login role=dev-role pkcs7="$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/pkcs7)" nonce=$nonce -format=json > /tmp/vault-aws.txt
cat /tmp/vault-aws.txt | jq -r .auth.client_token > /tmp/catalog_token

# Update systemd file
cp /lib/systemd/system/listing.service /lib/systemd/system/listing.service.backup
echo "Environment=VAULT_TOKEN=$(cat /tmp/catalog_token)" >> /lib/systemd/system/listing.service

# Start the service
systemctl daemon-reload
systemctl enable listing.service
systemctl start listing.service
