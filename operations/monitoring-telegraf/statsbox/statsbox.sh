#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

#
# Install prerequisites
#

apt-get update
apt-get install -y apt-transport-https ca-certificates curl \
  software-properties-common linux-image-extra-$(uname -r) \
  linux-image-extra-virtual chrony

#
# Install InfluxDB and friends
#

curl -sL https://repos.influxdata.com/influxdb.key | apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
apt-get update && apt-get -y install influxdb chronograf telegraf kapacitor
install -c -m 0644 /vagrant/statsbox/telegraf.conf /etc/telegraf

systemctl daemon-reload
systemctl enable telegraf
systemctl restart telegraf
systemctl enable influxdb
systemctl restart influxdb
systemctl enable chronograf
systemctl restart chronograf
systemctl enable kapacitor
systemctl restart kapacitor

#
# Install Grafana
#

curl https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
apt-get update && apt-get -y install grafana

systemctl daemon-reload
systemctl enable grafana-server

install -c -m 0644 /vagrant/statsbox/influxdb.yaml /etc/grafana/provisioning/datasources/influxdb.yaml

systemctl restart grafana-server
