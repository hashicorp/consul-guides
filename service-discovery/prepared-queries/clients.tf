resource "google_compute_instance" "client-east-web" {
  provider     = "google.east"
  count        = "${var.client_web_count}"
  name         = "client-east-web-${count.index + 1}"
  machine_type = "${var.client_machine_type}"
  zone         = "${data.google_compute_zones.east-azs.names[count.index]}"

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.east-client.self_link}"
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

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file(var.ssh_private_key_file_path)}"
    }

    inline = [
      "sudo mv /etc/consul/web.hcl.disabled /etc/consul/web.hcl",
      "sudo systemctl restart consul.service",
    ]
  }
}

resource "google_compute_instance" "client-west-web" {
  provider     = "google.west"
  count        = "${var.client_web_count}"
  name         = "client-west-web-${count.index + 1}"
  machine_type = "${var.client_machine_type}"
  zone         = "${data.google_compute_zones.west-azs.names[count.index]}"

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.west-client.self_link}"
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

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file(var.ssh_private_key_file_path)}"
    }

    inline = [
      "sudo mv /etc/consul/web.hcl.disabled /etc/consul/web.hcl",
      "sudo systemctl restart consul.service",
    ]
  }
}

resource "google_compute_instance" "client-west-cache" {
  provider     = "google.west"
  count        = "${var.client_cache_count}"
  name         = "client-west-cache-${count.index + 1}"
  machine_type = "${var.client_machine_type}"
  zone         = "${data.google_compute_zones.west-azs.names[count.index]}"

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.west-client.self_link}"
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

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file(var.ssh_private_key_file_path)}"
    }

    inline = [
      "sudo mv /etc/consul/cache.hcl.disabled /etc/consul/cache.hcl",
      "sudo systemctl restart consul.service",
    ]
  }
}

resource "google_compute_instance" "client-east-cache" {
  provider     = "google.east"
  count        = "${var.client_cache_count}"
  name         = "client-east-cache-${count.index + 1}"
  machine_type = "${var.client_machine_type}"
  zone         = "${data.google_compute_zones.east-azs.names[count.index]}"

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.east-client.self_link}"
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

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file(var.ssh_private_key_file_path)}"
    }

    inline = [
      "sudo mv /etc/consul/cache.hcl.disabled /etc/consul/cache.hcl",
      "sudo systemctl restart consul.service",
    ]
  }
}

resource "google_compute_instance" "client-west-db" {
  provider     = "google.west"
  count        = "${var.client_db_count}"
  name         = "client-west-db-${count.index + 1}"
  machine_type = "${var.client_machine_type}"
  zone         = "${data.google_compute_zones.west-azs.names[count.index]}"

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.west-client.self_link}"
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

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file(var.ssh_private_key_file_path)}"
    }

    inline = [
      "sudo mv /etc/consul/db.hcl.disabled /etc/consul/db.hcl",
      "sudo systemctl restart consul.service",
    ]
  }
}

resource "google_compute_instance" "client-east-db" {
  provider     = "google.east"
  count        = "${var.client_db_count}"
  name         = "client-east-db-${count.index + 1}"
  machine_type = "${var.client_machine_type}"
  zone         = "${data.google_compute_zones.east-azs.names[count.index]}"

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.east-client.self_link}"
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

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file(var.ssh_private_key_file_path)}"
    }

    inline = [
      "sudo mv /etc/consul/db.hcl.disabled /etc/consul/db.hcl",
      "sudo systemctl restart consul.service",
    ]
  }
}

resource "google_compute_instance" "client-esm" {
  provider     = "google.west"
  name         = "client-west-esm"
  machine_type = "${var.client_machine_type}"
  zone         = "${data.google_compute_zones.west-azs.names[0]}"

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.west-client.self_link}"
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

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file(var.ssh_private_key_file_path)}"
    }

    inline = [
      "wget https://releases.hashicorp.com/consul-esm/0.1.0/consul-esm_0.1.0_linux_amd64.zip",
      "sudo unzip consul-esm_0.1.0_linux_amd64.zip -d /usr/bin/",
      "sudo mkdir -p /etc/consul-esm",
      "echo 'datacenter = \"west\" ' > config.hcl && sudo mv config.hcl /etc/consul-esm/",
      "echo 'consul-esm -config-file=/etc/consul-esm/config.hcl' > ~/run-consul-esm.sh",
      "sudo nohup consul-esm -config-file=/etc/consul-esm/config.hcl &",
      "sleep 2",
    ]
  }
}
