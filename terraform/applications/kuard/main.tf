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

locals {
  resources = provider::kubernetes::manifest_decode_multi(file("manifests/kuard.yaml"))
}

resource "kubernetes_manifest" "kuard" {
  depends_on = [kubernetes_namespace.kuard]

  for_each = {
    for manifest in local.resources:
    "${manifest.kind}--${manifest.metadata.name}" => manifest
  }

  manifest = each.value
}
