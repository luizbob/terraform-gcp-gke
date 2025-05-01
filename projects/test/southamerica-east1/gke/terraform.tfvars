project_id   = "test"
region       = "southamerica-east1"
network_name = "test-vpc"
cluster_name = "test-gke"
max_pods_per_node = 110
pool_name     = "test-pool"
min_nodes     = 1
max_nodes     = 3
machine_type = "e2-medium"

#cost managment
common_labels = {
  environment = "production"
  managed-by  = "terraform"
  project     = "test-platform"
}

cluster_labels = {
  component   = "kubernetes"
}

node_labels = {
  workload-type = "general"
}
