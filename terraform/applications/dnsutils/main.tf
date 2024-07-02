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

resource "kubernetes_manifest" "dnsutils_pod" {
  manifest = provider::kubernetes::manifest_decode(file("manifests/dnsutils_pod.yaml"))
}
