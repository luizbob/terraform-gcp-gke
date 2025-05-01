remote_state {
  backend = "gcs"
  config = {
    bucket = "terraform-tfstate-production"
    prefix = "projects/test/${path_relative_to_include()}"
    location = "southamerica-east1"
    project = "test"
    
    # If you want to impersonate a service account, this can be configured here.
    # impersonate_service_account = "your-service-account@your-project-id.iam.gserviceaccount.com"
  }
}