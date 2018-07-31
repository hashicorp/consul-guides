ui = true

storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true
}

telemetry {
  dogstatsd_addr   = "127.0.0.1:8125"
  disable_hostname = true
}
