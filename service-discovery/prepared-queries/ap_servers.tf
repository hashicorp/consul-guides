resource "google_compute_instance" "ap-servers-east" {
  provider     = "google.east"
  count        = "${var.autopilot_servers_count}"
  name         = "ap-server-east-${count.index + 1}"
  machine_type = "${var.server_machine_type}"
  zone         = "${data.google_compute_zones.east-azs.names[count.index]}"

  tags = [
    "consul-server",
  ]

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.east-server.self_link}"
    }
  }

  network_interface {
    network = "${data.google_compute_network.east-network.self_link}"

    access_config {
      // ephemeral public IP
    }
  }

  metadata {
    sshKeys = "${var.ssh_user}:${file(var.ssh_pub_key_file_path)}"
  }

  lifecycle {
    //////create_before_destroy = true
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

  allow_stopping_for_update = true
}

resource "google_compute_instance" "ap-servers-west" {
  provider     = "google.west"
  count        = "${var.autopilot_servers_count}"
  name         = "ap-server-west-${count.index + 1}"
  machine_type = "${var.server_machine_type}"
  zone         = "${data.google_compute_zones.west-azs.names[count.index]}"

  tags = [
    "consul-server",
  ]

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.west-server.self_link}"
    }
  }

  network_interface {
    network = "${data.google_compute_network.west-network.self_link}"

    access_config {
      // ephemeral public IP
    }
  }

  metadata {
    sshKeys = "${var.ssh_user}:${file(var.ssh_pub_key_file_path)}"
  }

  lifecycle {
    //create_before_destroy = true
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

  allow_stopping_for_update = true
}
