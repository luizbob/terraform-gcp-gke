variable "project_id" {
  description = "The project ID where the VPC will be created"
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network"
  type        = string
}

variable "subnet_range" {
  description = "The primary IP range for the subnet"
  type        = string
}

variable "region" {
  description = "The region where the subnet will be created"
  type        = string
}

variable "services_range" {
  description = "The IP range for GKE services"
  type        = string
}

variable "pods_range" {
  description = "The IP range for GKE pods"
  type        = string
}
