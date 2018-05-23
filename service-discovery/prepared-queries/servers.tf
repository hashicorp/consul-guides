resource "google_compute_instance" "servers-east" {
  provider     = "google.east"
  count        = "${var.servers_count}"
  name         = "server-east-${count.index + 1}"
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
    //create_before_destroy = true
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }

  allow_stopping_for_update = true
}

resource "google_compute_instance" "servers-west" {
  provider     = "google.west"
  count        = "${var.servers_count}"
  name         = "server-west-${count.index + 1}"
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

  depends_on = [
    "google_compute_firewall.allow-consul-wan-east",
    "google_compute_firewall.allow-consul-wan-west",
    "google_compute_firewall.allow-consul-ui-west",
    "google_compute_firewall.allow-consul-ui-east",
  ]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      agent       = true
      private_key = "${file(var.ssh_private_key_file_path)}"
    }

    inline = [
      "sleep 30",
      "consul join -wan [${join(" ", google_compute_instance.servers-east.*.network_interface.0.access_config.0.assigned_nat_ip)}",
    ]
  }
}
