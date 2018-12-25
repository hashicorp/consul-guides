#! /bin/bash
cd /tmp

# Stop product service if up already
systemctl stop product.service

# Install hvac:
pip3 install hvac

# Download application
cd /tmp
git clone https://github.com/kawsark/thomas_cc_demo.git
cp -r /tmp/thomas_cc_demo/application/product-service /opt

# Create application directory and create a PID file:
cd /opt
chown -R ubuntu:ubuntu /opt/product-service
chmod a+x /opt/product-service/product_wrapper.sh
touch /tmp/product-service.pid
chown -R ubuntu:ubuntu /tmp

# Delay to ensure Consul agent is available
sleep 30

# Add product App specific configuration:
consul kv put product/config/version 1.0
consul kv put product/config/DB_ADDR mongodb.service.consul
consul kv put product/config/DB_PORT 27017
consul kv put product/config/DB_NAME bbthe90s
consul kv put product/config/COL_NAME products
consul kv put product/config/PRODUCT_PORT 5000
consul kv put product/config/PRODUCT_ADDR 0.0.0.0
consul kv put product/config/AWS_EC2_ROLE dev-role
consul kv put product/config/VAULT_SECRET_PATH mongo/creds/catalog

# Obtain nonce:
export nonce=$(date +%s%N | md5sum | awk '{print $1}')

# Adjust products.service file with VAULT_TOKEN
cp /lib/systemd/system/product.service /lib/systemd/system/product.service.backup
echo "Environment=AWS_EC2_NONCE=$nonce" >> /lib/systemd/system/product.service

# Start the service
systemctl daemon-reload
systemctl enable product.service
systemctl start product.service
