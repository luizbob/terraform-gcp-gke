variable "network_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}
variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}
variable "max_pods_per_node" {
  description = "Maximum number of pods per node in the GKE cluster"
  type        = number
  default     = 110
}
variable "pool_name" {
  description = "The name of the GKE node pool"
  type        = string
  default     = "default-pool"
}

variable "min_nodes" {
  description = "Minimum number of nodes in the GKE node pool"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Maximum number of nodes in the GKE node pool"
  type        = number
  default     = 3
}
variable "machine_type" {
  description = "The machine type for GKE nodes"
  type        = string
  default     = "e2-medium"
}
variable "cluster_labels" {
  description = "Labels to apply to the GKE cluster"
  type        = map(string)
  default     = {}
}

variable "node_labels" {
  description = "Labels to apply to the GKE nodes"
  type        = map(string)
  default     = {}
}
variable "common_labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}