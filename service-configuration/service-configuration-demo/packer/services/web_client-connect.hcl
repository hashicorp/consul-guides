service {
  name = "web_client"
  address = ""
  enable_tag_override = false
  port = 80
  tags = ["prod"]

  checks = [
    {
      id = "client-tcp"
      interval = "10s"
      name = "index server on 8080"
      tcp = "localhost:8080"
      timeout = "1s"
    },
    {
      id = "client-health"
      interval = "10s"
      timeout = "1s"
      name = "client server /healthz"
      http =  "http://localhost:8080/healthz",
      tls_skip_verify = true,
    }
  ] 

  connect = {
    proxy = {
      config = {
        upstreams = [
          {
            destination_name = "listing",
            local_bind_port = 10002
          },
          {
            destination_name = "product"
            local_bind_port  = 10001
          }
        ]
      }
    }
  }
}
