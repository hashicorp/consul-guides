#!/bin/bash

[ ! -n "$DEBUG" ] || set -x

set -ue

# the internet says this is better than 'set -e'
function onerr {
    echo 'Cleaning up after error...'

    exit -1     
}
trap onerr ERR

# install Chef Inspec used for config validation
function inspec_install() {
    echo '>>> Installing Chef Inspec for system validation...'
    if ! command inspec > /dev/null 2>&1 ; then
	(set -x; curl -s https://omnitruck.chef.io/install.sh | bash -s -- -P inspec)
    fi
}

# install some other tools we either need or which are convenient to have in place.
function tools_install() {
    # some supporting tooling
    echo '>>> Installing various support tools...'
    if ! command facter > /dev/null 2>&1 ; then
	(set -x; apt-get update)
	(set -x; apt-get install -y facter)
    fi
}

# the magic starts here
function main() {
    inspec_install
    tools_install
}

main
