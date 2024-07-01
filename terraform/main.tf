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

      kubeadm_config_patches = [
        "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
      ]

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
      extra_port_mappings {
        container_port = 30006
        host_port      = 30006
        listen_address  = "127.0.0.1"
        protocol       = "TCP"
      }
      extra_port_mappings {
        container_port = 30007
        host_port      = 30007
        listen_address  = "127.0.0.1"
        protocol       = "TCP"
      }
      extra_port_mappings {
        container_port = 30008
        host_port      = 30008
        listen_address  = "127.0.0.1"
        protocol       = "TCP"
      }
      extra_port_mappings {
        container_port = 30009
        host_port      = 30009
        listen_address  = "127.0.0.1"
        protocol       = "TCP"
      }
      extra_port_mappings {
        container_port = 30010
        host_port      = 30010
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

resource "cilium" "default" {
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

resource "helm_release" "argocd" {
  depends_on = [cilium.default]
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.3.0"

  values = [file("argocd.yaml")]
}


