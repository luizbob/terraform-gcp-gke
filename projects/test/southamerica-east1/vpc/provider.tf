provider "google" {
  project = var.project_id
  region  = var.region
  
  use_iap_tunneling = true
}