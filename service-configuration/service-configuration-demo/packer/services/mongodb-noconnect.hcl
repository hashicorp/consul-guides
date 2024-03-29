# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

service {
  name = "mongodb"
  address = ""
  enable_tag_override = false
  port = 27017
  tags = ["prod"]

  checks = [
    {
      id = "mongo"
      interval = "10s"
      name = "Mongo server on 27017"
      tcp = "localhost:27017"
      timeout = "1s"
    }
  ]
}
