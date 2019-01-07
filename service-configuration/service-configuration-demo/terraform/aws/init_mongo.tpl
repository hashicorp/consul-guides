#!/bin/bash

# Setup userid and password for Vault
export mongo_admin_user="vault-admin"
export mongo_admin_pass=$(date | base64)
cat <<EOF > admin.js
use admin
db.dropUser("$mongo_admin_user")
db.createUser({ user: "$mongo_admin_user", pwd: "$mongo_admin_pass", roles: [{ role: "userAdminAnyDatabase", db: "admin" }] })
EOF
mongo < admin.js

# Store password in /tmp:
sleep 5
echo $mongo_admin_user > /tmp/mongo_admin_user
echo $mongo_admin_pass > /tmp/mongo_admin_pass

# Restart mongodb with Authorization
cp /etc/mongod.conf /etc/mongod.conf.backup
echo "security:
    authorization: enabled" >> /etc/mongod.conf
systemctl restart mongod

# Setup Vault for Mongo:

# Install Vault client
apt-get update -y
apt-get install curl jq -y
curl -v -o vault.zip "https://releases.hashicorp.com/vault/${vault_client_version}/vault_${vault_client_version}_linux_amd64.zip"
unzip vault.zip
chown root:root vault
mv vault /usr/local/bin/vault
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault
vault --version

# Setup Vault endpoints:
# Note: using ${vault_server_ip} creates a dependency which is not yet supported in modules.
export VAULT_ADDR=http://${vault_server_ip}:8200
export VAULT_TOKEN=$(consul kv get vault_metadata/root_token)
consul kv delete vault_metadata/root_token
export mongo_server_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Setup MongoDB database secrets engine:
sleep 25
vault status > /tmp/status.txt
vault token lookup > /tmp/token_lookup.txt

vault secrets enable -path mongo database

vault write mongo/config/ec2-dev-mongo \
    plugin_name=mongodb-database-plugin \
    allowed_roles="catalog" \
    connection_url="mongodb://{{username}}:{{password}}@$mongo_server_ip:27017/admin?ssl=false" \
    username="$mongo_admin_user" \
    password="$mongo_admin_pass"

vault write mongo/roles/catalog \
    db_name=ec2-dev-mongo \
    creation_statements='{ "db": "admin", "roles": [{ "role": "readWrite" }, {"role": "read", "db": "bbthe90s"}] }' \
    default_ttl="2m" \
    max_ttl="4m"

# Set permissions for regular user:
chown -R ubuntu /tmp
