terraform {
  required_providers {
    kind = {
      source = "tehcyx/kind"
      version: "0.5.1"
    }
    cilium = {
      source = "littlejo/cilium"
      version = "~>0.1.0"
    }
  }
}

provider "kind" {}

provider "cilium" {
  config_path = kind_cluster.default.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = "./.kube/config"
  }
}

provider "kubernetes" {
  config_path = ".kube/config"
}
