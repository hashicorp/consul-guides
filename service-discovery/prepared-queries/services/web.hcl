service {
  name = "web"
  address = ""
  enable_tag_override = false
  port = 8080
  tags = ["primary"]

  checks = [
    {
      id = "ssh"
      interval = "10s"
      name = "Web server on 8080"
      tcp = "localhost:80"
      timeout = "1s"
    },
    {
      http = "http://localhost"
      id = "chk2"
      interval = "15s"
      name = "/health"
    }
  ]
}