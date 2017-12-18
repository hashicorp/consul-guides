#!/bin/bash

[ ! -n "$DEBUG" ] || set -x

set -ue

# the internet says this is better than 'set -e'
function onerr {
    echo 'Cleaning up after error...'

    exit -1     
}
trap onerr ERR

: ${CONSUL_VERSION:="1.0.1"}
: ${CONSUL_REMOTE_DIR:="s3://hc-enterprise-binaries/consul-enterprise/${CONSUL_VERSION}/"}
: ${CONSUL_REMOTE_FILE:="consul-enterprise_${CONSUL_VERSION}+ent_linux_amd64.zip"}

: ${REMOTE_LS:="aws s3 ls"}
: ${REMOTE_CP:="aws s3 cp --quiet"}

echo "Available Consul versions..."
${REMOTE_LS} ${CONSUL_REMOTE_DIR}
echo "Downloading ${CONSUL_REMOTE_FILE}..."
${REMOTE_CP} "${CONSUL_REMOTE_DIR}${CONSUL_REMOTE_FILE}" /tmp/consul.zip
(cd binaries && unzip -o /tmp/consul.zip)

