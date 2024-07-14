terraform {
  required_version = ">= 1.8.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.28.0"
    }
  }
}

provider "kubernetes" {
  config_path = "../../.kube/config"
}

locals {
  resources = provider::kubernetes::manifest_decode_multi(file("nginx.yaml"))
}

resource "kubernetes_manifest" "nginx" {
  for_each = {
    for manifest in local.resources :
    "${manifest.kind}--${manifest.metadata.name}" => manifest
  }

  manifest = each.value
}
