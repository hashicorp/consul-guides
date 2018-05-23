#! /bin/bash

sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq upgrade > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq puppet unzip wget jq webfs > /dev/null

sudo puppet module install KyleAnderson-consul

echo "Starting local web server for consul binary..."
sudo webfsd -r /tmp/ -p 8888

RETRY="provider=gce project_name=$2 tag_value=$3"

sudo puppet apply -e "class { '::consul':
  pretty_config      => true,
  install_method => 'url',
  download_url   => 'http://localhost:8888/consul.zip',
  service_ensure => 'stopped',
  service_enable => true,
  version        => '1.0.6',
  config_hash => {
    'client_addr'      => '0.0.0.0',
    'data_dir'         => '/opt/consul',
    'datacenter'       => '$1',
    'log_level'        => 'INFO',
    'retry_join'       => [
      '$RETRY'
    ],
  }
}"

sudo DEBIAN_FRONTEND=noninteractive apt-get remove -qq puppet > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove -qq > /dev/null
echo "Finished!"