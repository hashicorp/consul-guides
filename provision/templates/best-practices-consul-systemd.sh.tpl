#!/bin/bash

echo "[---Begin quick-start-consul-systemd.sh---]"

echo "Update resolv.conf"
sudo sed -i '1i nameserver 127.0.0.1\n' /etc/resolv.conf

echo "Set variables"
LOCAL_IPV4=$(curl -s ${local_ip_url})
CONSUL_TLS_PATH=/opt/consul/tls
CONSUL_CACERT_PATH="$CONSUL_TLS_PATH/ca.crt"
CONSUL_CLIENT_CERT_PATH="$CONSUL_TLS_PATH/consul.crt"
CONSUL_CLIENT_KEY_PATH="$CONSUL_TLS_PATH/consul.key"
CONSUL_CONFIG_FILE=/etc/consul.d/consul-server.json

echo "Create TLS dir for Consul certs"
sudo mkdir -pm 0755 $CONSUL_TLS_PATH

echo "Write Consul CA certificate to $CONSUL_CACERT_PATH"
cat <<EOF | sudo tee $CONSUL_CACERT_PATH
${consul_ca_crt}
EOF

echo "Write Consul certificate to $CONSUL_CLIENT_CERT_PATH"
cat <<EOF | sudo tee $CONSUL_CLIENT_CERT_PATH
${consul_leaf_crt}
EOF

echo "Write Consul certificate key to $CONSUL_CLIENT_KEY_PATH"
cat <<EOF | sudo tee $CONSUL_CLIENT_KEY_PATH
${consul_leaf_key}
EOF

echo "Configure Consul server"
cat <<CONFIG | sudo tee $CONSUL_CONFIG_FILE
{
  "datacenter": "${name}",
  "advertise_addr": "$LOCAL_IPV4",
  "data_dir": "/opt/consul/data",
  "client_addr": "0.0.0.0",
  "log_level": "INFO",
  "ui": true,
  "server": true,
  "bootstrap_expect": ${bootstrap_expect},
  "leave_on_terminate": true,
  "retry_join": ["provider=${provider} tag_key=Consul-Auto-Join tag_value=${name}"],
  "encrypt": "${serf_encrypt}",
  "ca_file": "$CONSUL_CACERT_PATH",
  "cert_file": "$CONSUL_CLIENT_CERT_PATH",
  "key_file": "$CONSUL_CLIENT_KEY_PATH",
  "verify_incoming": true,
  "verify_outgoing": true,
  "ports": { "https": 8080 }
}
CONFIG

echo "Update Consul configuration & certificates file permissions"
sudo chown -R consul:consul $CONSUL_CONFIG_FILE $CONSUL_TLS_PATH

echo "Don't start Consul in -dev mode"
echo '' | sudo tee /etc/consul.d/consul.conf

echo "Restart Consul"
sudo systemctl restart consul

echo "[---quick-start-consul-systemd.sh Complete---]"
