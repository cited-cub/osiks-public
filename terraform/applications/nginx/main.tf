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

resource "kubernetes_namespace" "nginx" {
  metadata {
    name = "nginx"
  }
}

resource "kubernetes_manifest" "pebble_issuer" {
  depends_on = [kubernetes_namespace.nginx]
    
  manifest = provider::kubernetes::manifest_decode(file("pebble_issuer.yaml"))
}

locals {
  resources = provider::kubernetes::manifest_decode_multi(file("nginx.yaml"))
}

resource "kubernetes_manifest" "nginx" {
  depends_on = [kubernetes_manifest.pebble_issuer]

  for_each = {
    for manifest in local.resources :
    "${manifest.kind}--${manifest.metadata.name}" => manifest
  }

  manifest = each.value
}
