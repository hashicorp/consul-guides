#! /bin/bash

# Install envconsul on Linux:
export envconsul_version=0.7.3
curl -so envconsul.tgz https://releases.hashicorp.com/envconsul/${envconsul_version}/envconsul_${envconsul_version}_linux_amd64.tgz
tar -xvzf envconsul.tgz
sudo mv envconsul /usr/local/bin/envconsul
sudo chmod +x /usr/local/bin/envconsul
envconsul --version

# Install Consul-template on Linux:
export consultemplate_version=0.19.5
curl -so consul-template.tgz https://releases.hashicorp.com/consul-template/${consultemplate_version}/consul-template_${consultemplate_version}_linux_amd64.tgz
tar -xvzf consul-template.tgz
sudo mv consul-template /usr/local/bin/consul-template
sudo chmod +x /usr/local/bin/consul-template
consul-template --version

# Install Mongo DB client for testing:
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

# Install Vault client for testing:
export vault_client_version="0.11.4"
apt-get update -y
apt-get install curl jq -y
curl -v -o vault.zip "https://releases.hashicorp.com/vault/${vault_client_version}/vault_${vault_client_version}_linux_amd64.zip"
unzip vault.zip
chown root:root vault
mv vault /usr/local/bin/vault
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault
vault --version
