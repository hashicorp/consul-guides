#! /bin/bash

export VAULT_VERSION="1.0.1"

# Setup pre-requisites
apt-get update
apt-get install -y git unzip curl jq dnsutils

# Add Vault user and vault.d directory:
useradd --system --home /etc/vault.d --shell /bin/false vault
mkdir -p /etc/vault.d
cp /tmp/vault.hcl /etc/vault.d/vault.hcl
sudo chmod 640 /etc/vault.d/vault.hcl
chown -R vault:vault /etc/vault.d

# Install Vault
curl -v https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -o vault.zip
unzip vault.zip
chown root:root vault
mv vault /usr/local/bin/vault
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault
vault --version

# Add vault to systemd
cp /tmp/vault.service /lib/systemd/system/vault.service
chmod 0644 /lib/systemd/system/vault.service
systemctl daemon-reload
systemctl enable vault.service
