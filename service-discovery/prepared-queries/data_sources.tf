data "google_compute_network" "east-network" {
  name     = "default"
  provider = "google.east"
}

data "google_compute_zones" "east-azs" {
  provider = "google.east"
}

data "google_compute_zones" "west-azs" {
  provider = "google.west"
}

data "google_compute_network" "west-network" {
  name     = "default"
  provider = "google.west"
}

data "google_compute_image" "east-server" {
  name = "east-gcp-ubuntu-consul-server"
}

data "google_compute_image" "west-server" {
  name = "west-gcp-ubuntu-consul-server"
}

data "google_compute_image" "east-client" {
  name = "east-gcp-ubuntu-consul-client"
}

data "google_compute_image" "west-client" {
  name = "west-gcp-ubuntu-consul-client"
}
