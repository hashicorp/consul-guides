exec {
  # This is the command to execute as a child process. There can be only one
  # command per process.
  command = "/opt/product-service/product_wrapper.sh"
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
pid_file = "/tmp/product-service.pid"

pristine = false
reload_signal = "SIGHUP"
sanitize = false

# Secret path:
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
