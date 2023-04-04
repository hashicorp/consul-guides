#! /bin/bash

echo "Updating and installing required software..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq upgrade > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq puppet unzip wget jq webfs > /dev/null

echo "Starting local web server for consul binary..."
sudo webfsd -r /tmp/ -p 8888

sudo puppet module install KyleAnderson-consul

echo "$MANIFEST"

MANIFEST=$(cat <<EOF
class { '::consul':
  pretty_config  => true,
  install_method => 'url',
  download_url   => 'http://localhost:8888/consul.zip',
  service_ensure => 'stopped',
  service_enable => true,
  version        => '1.0.6',
  config_hash   => {
    'bootstrap_expect'  => 3,
    'client_addr'       => '0.0.0.0',
    'data_dir'          => '/opt/consul',
    'datacenter'        => '$1',
    'log_level'         => 'INFO',
    'server'            => true,
    'ui'                => true,
    'non_voting_server' => false,
    
    'retry_join'        => [
      'provider=gce project_name=$2 tag_value=$3'
    ],
    'autopilot'         => {
      'cleanup_dead_servers'      => true,
      'last_contact_threshold'    =>'200ms',
      'max_trailing_logs'         => 250,
      'server_stabilization_time' => '10s',
      'redundancy_zone_tag'       => 'zone',
      'disable_upgrade_migration' => false,
      'upgrade_version_tag'       => '',
    },
    'node_meta' => { }
  }
}
EOF
)

sudo puppet apply -e "$MANIFEST"

sudo DEBIAN_FRONTEND=noninteractive apt-get remove -qq puppet > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get autoremove -qq > /dev/null

ls -l /opt/consul/

echo "Finished!"