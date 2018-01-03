#!/bin/bash

echo "[---Begin best-practices-bastion-systemd.sh---]"

echo "Update resolv.conf"
sudo sed -i '1i nameserver 127.0.0.1\n' /etc/resolv.conf

echo "Set variables"
local_ipv4=$(curl -s ${local_ip_url})

echo "Create pki dir for Consul certs"
sudo mkdir -pm 0755 /opt/consul/pki

echo "Write Consul CA certificate to /etc/consul.d/pki/ca.crt"
cat <<EOF | sudo tee /opt/consul/pki/ca.crt
${consul_ca_crt}
EOF

echo "Write Consul certificate to /etc/consul.d/pki/consul.crt"
cat <<EOF | sudo tee /opt/consul/pki/consul.crt
${consul_leaf_crt}
EOF

echo "Write Consul certificate key to /etc/consul.d/pki/consul.key"
cat <<EOF | sudo tee /opt/consul/pki/consul.key
${consul_leaf_key}
EOF

echo "Configure Bastion Consul client"
cat <<CONFIG | sudo tee /etc/consul.d/consul-client.json
{
  "datacenter": "${name}",
  "advertise_addr": "$${local_ipv4}",
  "data_dir": "/opt/consul/data",
  "client_addr": "0.0.0.0",
  "log_level": "INFO",
  "ui": true,
  "retry_join": ["provider=${provider} tag_key=Consul-Auto-Join tag_value=${name}"],
  "encrypt": "${serf_encrypt}",
  "ca_file": "/opt/consul/pki/ca.crt",
  "cert_file": "/opt/consul/pki/consul.crt",
  "key_file": "/opt/consul/pki/consul.key",
  "verify_incoming": true,
  "verify_outgoing": true,
  "ports": { "https": 8080 }
}
CONFIG

echo "Update Consul configuration & certificates file owners"
sudo chown -R consul:consul /etc/consul.d/consul-client.json /opt/consul/pki

echo "Don't start Consul in -dev mode"
echo '' | sudo tee /etc/consul.d/consul.conf

echo "Restart Consul"
sudo systemctl restart consul

echo "Stopping Vault & Nomad"
sudo systemctl stop vault
sudo systemctl stop nomad

echo "[---best-practices-bastion-systemd.sh Complete---]"
