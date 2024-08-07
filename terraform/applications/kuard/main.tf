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

resource "kubernetes_namespace" "kuard" {
  metadata {
    name = "kuard"
  }
}

resource "kubernetes_manifest" "kuard_issuer" {
  depends_on = [kubernetes_namespace.kuard]
  manifest = provider::kubernetes::manifest_decode(file("manifests/kuard_issuer.yaml"))
}

locals {
  resources = provider::kubernetes::manifest_decode_multi(file("manifests/kuard.yaml"))
}

resource "kubernetes_manifest" "kuard" {
  depends_on = [kubernetes_manifest.kuard_issuer]

  for_each = {
    for manifest in local.resources:
    "${manifest.kind}--${manifest.metadata.name}" => manifest
  }

  manifest = each.value
}

resource "kubernetes_manifest" "pebble_cm" {
  manifest = provider::kubernetes::manifest_decode(file("manifests/pebble_cm.yaml"))
}
