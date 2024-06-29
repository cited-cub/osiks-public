resource "kind_cluster" "default" {
  name            = "osiks-cluster"
  node_image      = "kindest/node:v1.27.1"
  kubeconfig_path = pathexpand(".kube/config")
  wait_for_ready  = true

  kind_config {
    kind          = "Cluster"
    api_version   = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control_plane"
      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }
      extra_port_mappings {
        container_port = 30000
        host_port      = 30000
        listen_address  = "127.0.0.1"
        protocol       = "TCP"
      }
      extra_port_mappings {
        container_port = 30001
        host_port      = 30001
        listen_address  = "127.0.0.1"
        protocol       = "TCP"
      }
      extra_port_mappings {
        container_port = 30002
        host_port      = 30002
        listen_address  = "127.0.0.1"
        protocol       = "TCP"
      }
      extra_port_mappings {
        container_port = 30003
        host_port      = 30003
        listen_address  = "127.0.0.1"
        protocol       = "TCP"
      }
      extra_port_mappings {
        container_port = 30004
        host_port      = 30004
        listen_address  = "127.0.0.1"
        protocol       = "TCP"
      }
      extra_port_mappings {
        container_port = 30005
        host_port      = 30005
        listen_address  = "127.0.0.1"
        protocol       = "TCP"
      }
    }

    node {
      role = "worker"
    }

    node {
      role = "worker"
    }

    node {
      role = "worker"
    }

    networking {
      disable_default_cni = true
    }
  }
}

resource "cilium" "lab" {
  depends_on = [kind_cluster.default]

  set = [
    "ipam.mode=kubernetes",
    "image.pullPolicy=IfNotPresent",
    "hubble.ui.enabled=true",
    "hubble.relay.enabled=true",
    "hubble.ui.service.type=NodePort",
    "hubble.ui.service.nodePort=30000"
  ]
  version = "1.15.6"
}

#resource "kubernetes_namespace" "argocd" {
#  depends_on = [cilium.lab]
#
#  lifecycle {
#    ignore_changes = [metadata]
#  }
#
#  metadata {
#    name = "argocd"
#  }
#}

#resource "time_sleep" "wait_30_seconds" {
#  depends_on = [kubernetes_namespace.argocd]
#
#  destroy_duration = "30s"
#}

resource "helm_release" "argocd" {
  depends_on = [cilium.lab]
#  depends_on = [time_sleep.wait_30_seconds]
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.3.0"

  values = [file("argocd.yaml")]
}

#data "kubernetes_secret" "argopass" {
#  metadata {
#    name = "argocd-initial-admin-secret"
#    namespace = "argocd"
#  }
#  binary_data = {
#    "password" = ""
#  }
#}
#
#resource "argocd_project" "osiks-public" {
#  metadata {
#    name        = "osiks-public"
#    namespace   = "argocd"
#  }
#
#  spec {
#    cluster_resource_whitelist {
#      group = "*"
#      kind = "*"
#    }
#    destination {
#      name = "*"
#      namespace = "*"
#      server = "*"
#    }
#    namespace_resource_whitelist {
#      group = "*"
#      kind = "*"
#    }
#    source_repos = ["*"]
#  }
#}
