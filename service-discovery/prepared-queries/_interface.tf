variable "project_id" {
  description = "Id of GCP project that has the packer images"
}

variable "server_machine_type" {
  description = "The machine type (size) to deploy"
  default     = "n1-standard-1"
}

variable "client_machine_type" {
  description = "The machine type (size) to deploy"
  default     = "g1-small"
}

variable "ssh_pub_key_file_path" {
  description = "Private key filename"
}

variable "ssh_private_key_file_path" {
  description = "Contents of the private key"
}

variable "ssh_user" {
  description = "Username of ssh user created with the ssh_key_data key"
  default     = "demo-consul"
}

variable "servers_count" {
  description = "How many servers to create in each region"
  default     = "3"
}

variable "autopilot_servers_count" {
  description = "How many servers to create in each region"
  default     = "3"
}

variable "client_db_count" {
  description = "The number of client machines to create in each region"
  default     = "1"
}

variable "client_cache_count" {
  description = "The number of client machines to create in each region"
  default     = "1"
}

variable "client_web_count" {
  description = "The number of client machines to create in each region"
  default     = "1"
}

variable "image_family" {
  default = "ubuntu-os-cloud/ubuntu-1710"
}

output "server_ips" {
  value = ["${google_compute_instance.servers-east.*.network_interface.0.access_config.0.assigned_nat_ip}"]
}
