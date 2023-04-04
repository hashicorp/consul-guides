service {
  name = "cache"
  address = ""
  enable_tag_override = false
  port = 6379
  tags = ["primary"]

  checks = [
    {
      id = "redis"
      interval = "10s"
      name = "Redis server on 6379"
      tcp = "localhost:6379"
      timeout = "1s"
    }
  ]
}