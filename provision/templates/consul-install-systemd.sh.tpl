#!/bin/bash

echo "Set variables"
export GROUP=${group}
export USER=${user}
export COMMENT=${comment}
export HOME=${home}
export VERSION=${version}
export URL=${url}

echo "Download scripts"
curl https://raw.githubusercontent.com/hashicorp/guides-configuration/f-refactor/shared/scripts/download-guides-configuration.sh | sudo bash

echo "Run base script"
bash /tmp/shared/scripts/base.sh

echo "Setup Consul user"
bash /tmp/shared/scripts/setup-user.sh

echo "Install Consul"
bash /tmp/consul/scripts/install-consul.sh

echo "Install Consul Systemd"
bash /tmp/consul/scripts/install-consul-systemd.sh
