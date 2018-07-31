provider "grafana" {
  url  = "http://localhost:3000/"
  auth = "admin:admin"
}

resource "grafana_data_source" "influxdb" {
  type          = "influxdb"
  name          = "influxdb"
  url           = "http://localhost:8086"
  username      = "telegraf"
  password      = "telegraf"
  database_name = "telegraf"
}

resource "grafana_dashboard" "consul_cluster_health" {
  config_json = "${file("./dashboards/consul_cluster_health.json")}"
  depends_on  = ["grafana_data_source.influxdb"]
}
