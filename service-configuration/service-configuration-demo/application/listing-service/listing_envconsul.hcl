exec {
  # This is the command to execute as a child process. There can be only one
  # command per process.
  command = "/usr/bin/node /opt/listing-service/server.js"
  splay = "5s"

  env {
    pristine = false
  }

  kill_signal = "SIGTERM"
  kill_timeout = "2s"
}

kill_signal = "SIGINT"
log_level = "info"
max_stale = "10m"
pid_file = "/tmp/listing-service.pid"

pristine = false
reload_signal = "SIGHUP"
sanitize = false

# Configuration path in Consul:
# This specifies a prefix in Consul to watch. This may be specified multiple
prefix {
  # This tells Envconsul to not prefix the keys with their parent "folder".
  no_prefix = false

  # This is the path of the key in Consul or Vault from which to read data.
  path = "listing/config"
}


# Secret path in Vault:
secret {
  no_prefix = true
  path = "mongo/creds/catalog"
}

syslog {
  enabled = true
  facility = "LOCAL5"
}

upcase = false

vault {
  grace = "15s"
  # token = ""
  unwrap_token = false
  # This option tells Envconsul to automatically renew the Vault token given.
  renew_token = true

  retry {
    enabled = true
    attempts = 12
    backoff = "250ms"
    max_backoff = "1m"
  }
  ssl {
    enabled = false
  }
}

# This is the quiescence timers
wait {
  min = "2s"
  max = "5s"
}
