resource "helm_release" "sample_app" {
  name             = var.app_name
  chart            = "${path.module}/chart"
  namespace        = var.namespace
  create_namespace = true
  timeout          = 600
  
  # Valores configuráveis via Terraform
  set {
    name  = "replicaCount"
    value = var.replica_count
  }
  
  set {
    name  = "image.repository"
    value = var.image_repository
  }
  
  set {
    name  = "image.tag"
    value = var.image_tag
  }
  
  # Configuração de ingress
  set {
    name  = "ingress.enabled"
    value = true
  }
  
  set {
    name  = "ingress.className"
    value = "kong"
  }
  
  set {
    name  = "ingress.path"
    value = var.ingress_path
  }
  
  # Configuração de JWT (opcional)
  set {
    name  = "jwt.enabled"
    value = var.enable_jwt
  }
  
  # Labels para controle de custos
  dynamic "set" {
    for_each = var.labels
    content {
      name  = "labels.${set.key}"
      value = set.value
    }
  }
  
  depends_on = [data.google_container_cluster.gke_cluster]
}

resource "helm_release" "rabbitmq" {
  name             = "rabbitmq"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "rabbitmq"
  namespace        = "rabbitmq"
  create_namespace = true
  version          = "12.0.0"
  
  values = [
    file("${path.module}/rabbitmq/values.yaml")
  ]
  
  depends_on = [data.google_container_cluster.gke_cluster]
}


resource "kubernetes_manifest" "kong_consumer" {
  count = var.enable_jwt ? 1 : 0
  
  manifest = {
    apiVersion = "configuration.konghq.com/v1"
    kind       = "KongConsumer"
    metadata = {
      name = "${var.app_name}-consumer"
      annotations = {
        "kubernetes.io/ingress.class" = "kong"
      }
    }
    username = var.app_name
  }
  
  depends_on = [helm_release.sample_app]
}

resource "kubernetes_manifest" "kong_jwt_credential" {
  count = var.enable_jwt ? 1 : 0
  
  manifest = {
    apiVersion = "configuration.konghq.com/v1"
    kind       = "KongPlugin"
    metadata = {
      name = "${var.app_name}-jwt-credential"
      annotations = {
        "kubernetes.io/ingress.class" = "kong"
      }
    }
    plugin = "jwt"
    consumerRef = "${var.app_name}-consumer"
    config = {
      # Better approach using Google Secret Manager:
      # key     = data.google_secret_manager_secret_version.jwt_key.secret_data
      # secret  = data.google_secret_manager_secret_version.jwt_secret.secret_data
      key       = var.jwt_key
      secret    = var.jwt_secret
      algorithm = "HS256"
    }
  }
  
  depends_on = [kubernetes_manifest.kong_consumer]
}

# Example of Secret Manager implementation (add to data.tf):
# data "google_secret_manager_secret_version" "jwt_key" {
#   project = var.project_id
#   secret  = "jwt-key"
#   version = "latest"
# }
# 
# data "google_secret_manager_secret_version" "jwt_secret" {
#   project = var.project_id
#   secret  = "jwt-secret"
#   version = "latest"
# }