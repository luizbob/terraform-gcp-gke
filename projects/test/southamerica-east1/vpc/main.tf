module "vpc" {
  source = "terraform-google-modules/network/google"
  version = "~> 11.0"

  project_id   = var.project_id
  network_name = var.network_name
  

  subnets = [
    {
      subnet_name           = "${var.network_name}-sub"
      subnet_ip            = var.subnet_range
      subnet_region        = var.region
      subnet_private_access = "true"
    }
  ]
  secondary_ranges = {
    "${var.network_name}-sub" = [
      {
        range_name    = "${var.network_name}-services"
        ip_cidr_range = var.services_range
      },
      {
        range_name    = "${var.network_name}-pods"
        ip_cidr_range = var.pods_range
      }
    ]
  }
}

module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 6.0"
  name    = "${var.project_id}-router"
  project = var.project_id
  network = module.vpc.network_name
  region  = var.region

  nats = [{
    name                               = "${var.project_id}-nat"
    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    subnetworks = [
      {
        name                     = module.vpc.subnets["${var.region}/${var.network_name}-sub"].id
        source_ip_ranges_to_nat  = ["PRIMARY_IP_RANGE", "LIST_OF_SECONDARY_IP_RANGES"]
        secondary_ip_range_names = module.vpc.subnets["${var.region}/${var.network_name}-sub"].secondary_ip_range[*].range_name
      }
    ]
  }]
}

resource "google_compute_firewall" "allow_iap" {
  name    = "allow-iap-ingress"
  network = module.vpc.network_name
  
  allow {
    protocol = "tcp"
    ports    = ["22", "3389"] # SSH e RDP
  }
  
  source_ranges = ["35.235.240.0/20"] # Range de IPs do IAP
}