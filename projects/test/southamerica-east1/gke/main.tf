module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version = "~> 36.0"

  project_id                  = var.project_id
  name                        = var.cluster_name
  regional                    = true
  region                      = var.region
  network                     = data.google_compute_network.vpc.name
  subnetwork                  = data.google_compute_subnetwork.subnet.name
  ip_range_pods               = "${var.network_name}-pods"
  ip_range_services           = "${var.network_name}-services"
  create_service_account      = true
  enable_private_endpoint     = true
  enable_private_nodes        = true
  enable_secret_manager_addon = true
  default_max_pods_per_node   = var.max_pods_per_node
  remove_default_node_pool    = true
  deletion_protection         = false
  cluster_resource_labels = merge(
    var.common_labels,
    var.cluster_labels,
    {
      "cluster_name" = var.cluster_name
    }
  )

  node_pools = [
    {
      name              = var.pool_name
      min_count         = var.min_nodes
      max_count         = var.max_nodes
      machine_type      = var.machine_type
      local_ssd_count   = 0
      disk_size_gb      = 100
      disk_type         = "pd-standard"
      auto_repair       = true
      auto_upgrade      = true
      preemptible       = false
      max_pods_per_node = var.max_pods_per_node
      node_labels = merge(
        var.common_labels,
        var.node_labels,
        {
          "node-pool" = var.pool_name
        }
      )
    },
  ]

  master_authorized_networks = [
    {
      cidr_block   = data.google_compute_subnetwork.subnet.ip_cidr_range
      display_name = "VPC"
    },
  ]
}

resource "helm_release" "kong" {
  name       = "kong"
  repository = "https://charts.konghq.com"
  chart      = "kong"
  namespace  = "kong"
  create_namespace = true
  
  # Valores para o Kong
  values = [
    file("kong/values.yaml")
  ]
  
  depends_on = [module.gke]
}
