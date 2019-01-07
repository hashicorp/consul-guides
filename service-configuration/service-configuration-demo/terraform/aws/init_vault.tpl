#!/bin/bash

cd /tmp

# Stop vault if already running
systemctl stop vault
pkill vault

# Write a new vault.hcl file to with a unique storage prefix.
# This will let us taint the vault server and allow for another instance to bootstrap successfully
cp /etc/vault.d/vault.hcl /etc/vault.d/vault.hcl.backup
cat <<EOF > /etc/vault.d/vault.hcl
listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = "true"
}
storage "consul" {
  address = "127.0.0.1:8500"
  path    = "${vault_path}/"
}
ui = "true"
EOF

# Delay Vault start to allow consul to come up:
sleep 10
systemctl daemon-reload
systemctl start vault

# Delay vault initialization
sleep 10

# check if consul servers are up (pending), if so delay initialization:
echo "Consul server 0: ${consul_server_ip0}"
consul_is_up=$(consul members | grep alive.*server)
if [ -z "$consul_is_up" ]
then
      echo "Consul is not up ... sleeping 10 secs"
      sleep 10
else
      echo "Consul is up, proceeding with Initialization"
fi

# Initialize and unseal:
export VAULT_ADDR="http://localhost:8200"
vault operator init -format=json -n 1 -t 1 > /tmp/${vault_path}.txt
cat /tmp/${vault_path}.txt | jq -r '.unseal_keys_b64[0]' > /tmp/${vault_path}_unseal_key
cat /tmp/${vault_path}.txt | jq -r .root_token > /tmp/${vault_path}_root_token
export VAULT_TOKEN=$(cat /tmp/${vault_path}_root_token)

# Setup profile:
echo "export VAULT_ADDR=\"http://localhost:8200\"" >> /etc/profile.d/vault.sh
echo "export VAULT_TOKEN=\"$(cat /tmp/${vault_path}_root_token)\"" >> /etc/profile.d/vault.sh

sleep 10
vault operator unseal $(cat /tmp/${vault_path}_unseal_key)
consul kv delete vault_metadata/root_token $VAULT_TOKEN
consul kv put vault_metadata/root_token $VAULT_TOKEN

# Import the Catalog policy
cat <<EOF > /tmp/catalog.policy
path "mongo/creds/catalog" {
  capabilities = ["read"]
}
EOF
vault policy write catalog /tmp/catalog.policy

# Create AWS Authentication:
export amis=${product_ami},${listing_ami},${mongo_ami} # Restrict via Account AMI IDs
vault auth enable aws
vault write auth/aws/role/dev-role auth_type=ec2 bound_account_id=${account_id} bound_ami_id=$amis policies=catalog max_ttl=500h

# Adjust permissions
chown -R ubuntu /tmp
