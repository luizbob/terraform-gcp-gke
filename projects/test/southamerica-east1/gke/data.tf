data "google_compute_network" "vpc" {
  name    = var.network_name
  project = var.project_id
}

data "google_compute_subnetwork" "subnet" {
  name    = "${var.network_name}-sub"
  region  = var.region
  project = var.project_id

  secondary_ip_range {
    range_name = "${var.network_name}-services"
  }

  secondary_ip_range {
    range_name = "${var.network_name}-pods"
  }
}
