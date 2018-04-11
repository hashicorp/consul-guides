#!/bin/bash

[ ! -n "$DEBUG" ] || set -x

set -ue

# the internet says this is better than 'set -e'
function onerr {
    echo 'Cleaning up after error...'

    exit -1     
}
trap onerr ERR

# configure Consul
function consul_config() {
    echo '>>> Installing and configuring HashiCorp Consul Enterprise...'
    cp -f /vagrant/binaries/consul /usr/local/bin/consul
    rm -rf /var/hashicorp/consul
    mkdir -p /etc/hashicorp/consul /var/hashicorp/consul

    ipaddress=`facter ipaddress_enp0s8`

cat <<EOF > /etc/hashicorp/consul/consul.hcl
datacenter="vagrant"
data_dir="/var/hashicorp/consul"
log_level="DEBUG"
server=true
ui=true
bind_addr="${ipaddress}"
client_addr="0.0.0.0"
raft_protocol=3
EOF

    # is we are consula0 then go ahead and bootstrap
    if [ 'consula0' == `hostname` ] ; then
	echo 'bootstrap=true' >> /etc/hashicorp/consul/consul.hcl
    else
	echo 'retry_join=["consula0"]' >> /etc/hashicorp/consul/consul.hcl
    fi

    # creates the node tag which we can use for automated upgrades which
    # do not change the Consul version
    if [[ `hostname` == *"consula"* ]]; then
	NODE_META="cluster_version:0.0.1"
    else
	NODE_META="cluster_version:1.0.0"
    fi
    
cat <<EOF > /etc/systemd/system/hashicorp-consul-enterprise.service
[Unit]
Description=HashiCorp Consul Enterprise
After=networking.target

[Service]
Type=simple
User=root
WorkingDirectory=/var/hashicorp/consul
ExecStart=/usr/local/bin/consul agent -config-file=/etc/hashicorp/consul/consul.hcl -node-meta=${NODE_META}
Restart=on-abort
EOF

    chmod 644 /etc/systemd/system/hashicorp-consul-enterprise.service
    systemctl enable hashicorp-consul-enterprise.service
    systemctl restart hashicorp-consul-enterprise.service
#    pgrep consul > /dev/null || systemctl restart hashicorp-consul-enterprise.service
}

# sleep while Consul quorum settles
function consul_quorum_settle() {
    if [ "consul2b" == `hostname` ]; then
	SLEEP=90
    else
	SLEEP=20
    fi
    echo '>>> Sleeping to allow Consul quorum to settle...'
    (set -x ; sleep "${SLEEP}")
}

# the magic starts here
function main() {
    consul_config
    consul_quorum_settle
}

main

    
