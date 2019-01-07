# This denotes the start of the configuration section for Consul. All values
# contained in this section pertain to Consul.
consul {
  # This is the address of the Consul agent. By default, this is
  address = "127.0.0.1:8500"
}

# This is the signal to listen for to trigger a reload event. The default
reload_signal = "SIGHUP"

kill_signal = "SIGINT"
log_level = "info"
max_stale = "10m"
pid_file = "/tmp/product-service.pid"

# This is the quiescence timers; it defines the minimum and maximum amount of
wait {
  min = "5s"
  max = "10s"
}

syslog {
  enabled = true
  facility = "LOCAL5"
}

# This block defines the configuration for exec mode. Please see the exec mode
# documentation at the bottom of this README for more information on how exec
# mode operates and the caveats of this mode.
exec {
  command = "/usr/bin/python3 /opt/product-service/product.py"
  splay = "5s"

  env {
    pristine = false
  }

  kill_signal = "SIGTERM"
  kill_timeout = "2s"
}

# This block defines the configuration for a template. Unlike other blocks,
# this block may be specified multiple times to configure multiple templates.
# It is also possible to configure templates via the CLI directly.
template {
  # This is the source file on disk to use as the input template. This is often
  # called the "Consul Template template". This option is required if not using
  # the `contents` option.
  source = "/opt/product-service/config.ctpl"

  # This is the destination path on disk where the source template will render.
  # If the parent directories do not exist, Consul Template will attempt to
  # create them, unless create_dest_dirs is false.
  destination = "/opt/product-service/config.yml"

  # This options tells Consul Template to create the parent directories of the
  # destination path if they do not exist. The default value is true.
  create_dest_dirs = true

  # This option allows embedding the contents of a template in the configuration
  # contents = "{{ keyOrDefault \"service/redis/maxconns@east-aws\" \"5\" }}"

  # This is the optional command to run when the template is rendered. The
  # command = "restart service foo"

  # This is the maximum amount of time to wait for the optional command to
  # return. Default is 30s.
  # command_timeout = "60s"

  # Exit with an error when accessing a struct or map field/key that does not
  error_on_missing_key = false

  # This is the permission to render the file. If this option is left
  perms = 0600

  # This option backs up the previously rendered template at the destination
  backup = true

  # This is the `minimum(:maximum)` to wait before rendering a new template to
  wait {
    min = "2s"
    max = "10s"
  }
}
