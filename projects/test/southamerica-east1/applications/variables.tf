variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "app_name" {
  description = "App Name"
  type        = string
  default     = "sample-app"
}

variable "namespace" {
  description = "Kubernetes Namespace for the Application"
  type        = string
  default     = "default"
}

variable "replica_count" {
  description = "Number of replicas to deploy"
  type        = number
  default     = 2
}

variable "image_repository" {
  description = "Docker Registry"
  type        = string
  default     = "nginxdemos/hello"
}

variable "image_tag" {
  description = "Docker Tag"
  type        = string
  default     = "latest"
}

variable "ingress_path" {
  description = "Ingress Path"
  type        = string
  default     = "/api"
}

variable "enable_jwt" {
  description = "Enable or Disable JWT"
  type        = bool
  default     = false
}

variable "jwt_key" {
  description = "JWT Key"
  type        = string
  default     = "app-key"
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT Secret"
  type        = string
  default     = "app-secret"
  sensitive   = true
}

variable "labels" {
  description = "App Labels"
  type        = map(string)
  default     = {
    environment = "development"
    team        = "backend"
  }
}

variable "cluster_name" {
  description = "Cluster Name"
  type        = string
}