resource "google_compute_firewall" "allow-consul-ui-east" {
  provider = "google.east"
  name     = "consul-ui-east"
  network  = "${data.google_compute_network.east-network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["8302", "8500"]
  }
}

resource "google_compute_firewall" "allow-consul-wan-east" {
  provider = "google.east"
  name     = "consul-wan-east"
  network  = "${data.google_compute_network.east-network.self_link}"

  allow {
    protocol = "udp"
    ports    = ["8302"]
  }
}

resource "google_compute_firewall" "allow-consul-ui-west" {
  provider = "google.west"
  name     = "consul-ui-west"
  network  = "${data.google_compute_network.west-network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["8302", "8500"]
  }
}

resource "google_compute_firewall" "allow-consul-wan-west" {
  provider = "google.west"
  name     = "consul-wan-west"
  network  = "${data.google_compute_network.west-network.self_link}"

  allow {
    protocol = "udp"
    ports    = ["8302"]
  }
}

# client resources
resource "google_compute_firewall" "allow-services-west" {
  provider = "google.west"
  name     = "http-west"
  network  = "${data.google_compute_network.west-network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

resource "google_compute_firewall" "allow-services-east" {
  provider = "google.east"
  name     = "http-east"
  network  = "${data.google_compute_network.east-network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}
