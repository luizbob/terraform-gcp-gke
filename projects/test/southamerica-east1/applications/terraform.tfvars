project_id       = "test"
region           = "southamerica-east1"
cluster_name     = "test-gke"
app_name         = "sample-app"
namespace        = "apps"
replica_count    = 2
image_repository = "nginxdemos/hello"
image_tag        = "latest"
ingress_path     = "/api"
enable_jwt       = true
jwt_key          = "app-key" #THESE CONFIGURATIONS ARE AS EXAMPLE, FOR BEST APPROACH, USE A GOOGLE SECRET BASED VALUES.
jwt_secret       = "app-secret" #THESE CONFIGURATIONS ARE AS EXAMPLE, FOR BEST APPROACH, USE A GOOGLE SECRET BASED VALUES.
labels = {
  environment = "development"
  team        = "backend"
  application = "sample-api"
}