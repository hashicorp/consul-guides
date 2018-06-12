# Monitoring Consul with Telegraf

A simple Vagrant instance of a 3 node Consul cluster backing a Vault instance, sending metrics to Grafana via InfluxDB

* statsbox - The Grafana instance
* consul0 - Consul Server
* consul1 - Consul Server
* consul2 - Consul Server
* vault0 - Vault Server with Consul client

## Setup

 1. Clone this project from Github.
 2. Install the `vagrant-hosts` plugin: `vagrant plugin install vagrant-hosts`
 3. Install the `vagrant-vbguest` plugin: `vagrant plugin install vagrant-vbguest`
 4. Run `vagrant up` and wait a while.

You now have Grafana running on localhost:3000, and Consul UI running on localhost:8500

## Configuring Grafana

 1. Run `terraform apply` in this directory
 2. The datasource and dashboard should be created by Terraform:

```
grafana_data_source.influxdb: Modifying... (ID: 1)
  is_default: "true" => "false"
  password:   "" => "telegraf"
  username:   "" => "telegraf"
grafana_data_source.influxdb: Modifications complete after 1s (ID: 1)
grafana_dashboard.consul_cluster_health: Creating...
  config_json: "" => <SNIP>}"
  slug:        "" => "<computed>"
grafana_dashboard.consul_cluster_health: Creation complete after 0s (ID: consul-cluster-health)

Apply complete! Resources: 1 added, 1 changed, 0 destroyed.
```

## Preview

You should get a dashboard that looks something like this:

<div class="center">
![image](https://user-images.githubusercontent.com/1064715/41462997-c70010aa-708c-11e8-8f87-28634de717f9.png)
</div>

## Troubleshooting

### Missing Metrics

If metrics are missing, check the Chronograf data explorer to see if there is any data for that particular metric.

It might be that there is no data for that metric, for example missing k/v entries. Initialising Vault and adding data should be enough to trigger metrics for all those in the dashboard.
