#!/bin/bash

[ ! -n "$DEBUG" ] || set -x

set -ue

# the internet says this is better than 'set -e'
function onerr {
    echo 'Cleaning up after error...'

    exit -1     
}
trap onerr ERR

export RUBYOPT=-W0
echo ">>> Validating Consul..."
(set -x; \
 inspec exec /vagrant/vms/consul/validate.d/inspec/consul.rb)
