provider "consul" {
  alias = "east"

  //address    = "${element(google_compute_instance.servers-east.*.network_interface.0.access_config.0.assigned_nat_ip, 0)}:8500"
  address    = "SERVER_EAST_1_PUBLIC_IP:8500"
  datacenter = "east"
}

provider "consul" {
  alias   = "west"
  address = "SERVER_WEST_1_PUBLIC_IP:8500"

  // Ideally we could do this with remote state
  //address    = "${element(google_compute_instance.servers-west.*.network_interface.0.access_config.0.assigned_nat_ip, 0)}:8500"
  datacenter = "west"
}

resource "consul_prepared_query" "db-query" {
  provider     = "consul.east"
  name         = "db"
  only_passing = true
  near         = "_agent"

  service = "db"
  tags    = ["primary", "!dev"]

  failover {
    nearest_n   = 1
    datacenters = ["east", "west"]
  }

  dns {
    ttl = "30s"
  }
}

/*resource "consul_prepared_query" "db-query-east" {
  provider     = "consul.east"
  name         = "db-east"
  datacenter   = "east"
  only_passing = true
  near         = "_agent"

  service = "db"
  tags    = ["primary", "!dev"]

  failover {
    nearest_n   = 1
    datacenters = ["west"]
  }

  dns {
    ttl = "30s"
  }
}*/

