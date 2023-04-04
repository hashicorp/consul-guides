provider "google" {
  region  = "us-east1"
  project = "${var.project_id}"
  alias   = "east"
}

provider "google" {
  region  = "us-west1"
  project = "${var.project_id}"
  alias   = "west"
}
