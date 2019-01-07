service {
  name = "listing"
  address = ""
  enable_tag_override = false
  port = 8000
  tags = ["prod"]

  checks = [
    {
      id = "listing-tcp"
      interval = "10s"
      name = "Listing server on 8000"
      tcp = "localhost:8000"
      timeout = "1s"
    },
    {
      id = "listing-health"
      interval = "10s"
      timeout = "1s"
      name = "Listing server /healthz"
      http =  "http://localhost:8000/listing/healthz",
      tls_skip_verify = true,
    }
  ]
}
