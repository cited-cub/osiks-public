terraform {
  required_version = ">= 1.8.0"

  required_providers {
    kind = {
      source = "tehcyx/kind"
      version: "0.5.1"
    }
    cilium = {
      source = "littlejo/cilium"
      version = "~>0.1.0"
    }

    kubectl = {
      source = "alekc/kubectl"
      version = ">= 2.0.2"
    }

    helm = {
      source = "hashicorp/helm"
      version = "2.5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.28.0"
    }
  }
}

provider "kind" {}

provider "cilium" {
  config_path = kind_cluster.default.kubeconfig_path
}

provider "kubectl" {
  config_path = kind_cluster.default.kubeconfig_path
}
  
provider "helm" {
  kubernetes {
    #config_path = "./.kube/config"
    config_path = kind_cluster.default.kubeconfig_path
  }
}

provider "kubernetes" {
  #config_path = "./.kube/config"
  config_path = kind_cluster.default.kubeconfig_path
}

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

#resource "helm_release" "argocd" {
#  depends_on = [cilium.default]
#  name = "argocd"
#
#  repository       = "https://argoproj.github.io/argo-helm"
#  chart            = "argo-cd"
#  namespace        = "argocd"
#  create_namespace = true
#  version          = "7.3.0"
#
#  values = [file("argocd.yaml")]
#}

#module "ingress-controller" {
#  depends_on = [cilium.default]
#
#  source = "./applications/ingress-controller"
#}

resource "helm_release" "ingress-nginx" {
  name = "ingress-nginx"

  repository  = "https://kubernetes.github.io/ingress-nginx"
  chart       = "ingress-nginx"
  namespace   = "ingress-nginx"
  create_namespace  = true
  version           = "4.10.1"

  set {
    name = "controller.service.type"
    value = "NodePort"
  }

  set {
    name = "controller.service.nodePorts.http"
    value = "30009"
  }

  set {
    name = "controller.service.nodePorts.https"
    value = "30010"
  }
}

#module "cert-manager" {
#  depends_on = [module.ingress-controller]
#
#  source = "./applications/cert-manager"
#}

#module "cert-manager" {
#  source = "terraform-iaac/cert-manager/kubernetes"
#
#  cluster_issuer_email = "admin@mysite.com"
#  cluster_issuer_name = "pebble"
#  cluster_issuer_private_key_secret_name = "cert-manager-private-key"
#  cluster_issuer_server = "https://pebble.pebble/dir"
#
#  solvers = [
#    {
#      http01 = {
#        ingress = {
#          class = "nginx"
#        }
#      }
#    }
#  ]
#}
#
#module "pebble" {
#  depends_on = [module.cert-manager]
#
#  source = "./applications/pebble"
#}

#module "nginx" {
#  depends_on = [module.pebble]
#
#  source = "./applications/nginx"
#}

#resource "kubernetes_namespace" "nginx" {
#  metadata {
#    name = "nginx"
#  }
#}
#
##locals {
##  resources = provider::kubernetes::manifest_decode_multi(file("./applications/nginx/nginx.yaml"))
##}
#
#resource "kubernetes_pod" "nginx" {
#  metadata {
#    name = "nginx"
#    namespace = "nginx"
#    labels = {
#      run = "nginx"
#    }
#  }
#  spec {
#    container {
#      image = "nginx"
#      name = "nginx"
#    }
#  }
#}
#
#resource "kubernetes_service" "nginx" {
#  metadata {
#    name = "nginx"
#    namespace = "nginx"
#    labels = {
#      run = "nginx"
#    }
#  }
#  spec {
#    selector = {
#      run = "nginx"
#    }
#    port {
#      port = 80
#      protocol = "TCP"
#      target_port = 80
#      node_port = 30008
#    }
#    type = "NodePort"
#  }
#}
#
#resource "kubernetes_ingress_v1" "nginx" {
#  metadata {
#    name = "nginx"
#    annotations = {
#      "cert-manager.io/cluster-issuer" = "pebble"
#    }
#    namespace = "nginx"
#  }
#  spec {
#    ingress_class_name = "nginx"
#    tls {
#      hosts = ["osiks.local"]
#      secret_name = "osiks-local-tls"
#    }
#    rule {
#      http {
#        path {
#          path_type = "Prefix"
#          path = "/"
#          backend {
#            service {
#              name = "nginx"
#              port {
#                number = 80
#              }
#            }
#          }
#        }
#      }
#      host = "osiks.local"
#    }
#  }
#}



#resource "kubernetes_manifest" "pebble_issuer" {
#  manifest = {
#    "apiVersion" = "cert-manager.io/v1"
#    "kind" = "Issuer"
#    "metadata" = {
#      "name" = "pebble"
#      "namespace" = "nginx"
#    }
#    "spec" = {
#      "acme" = {
#        "skipTLSVerify" = "true"
#        "email" = "user-nginx@osiks.com"
#        "server" = "https://pebble.pebble/dir"
#        "privateKeySecretRef" = {
#          "name" = "pebble-account-private-key"
#        }
#        "solvers" = {
#          "http01" = {
#            "ingress" = {
#              "ingressClassName" = "nginx"
#            }
#          }
#        }
#      }
#    }
#  }
#}

#resource "kubernetes_manifest" "nginx" {
#  depends_on = [kubernetes_namespace.nginx]
#
#  for_each = {
#    for manifest in local.resources :
#    "${manifest.kind}--${manifest.metadata.name}" => manifest
#  }
#
#  manifest = each.value
#}

resource "terraform_data" "patch_coredns" {
  depends_on = [helm_release.ingress-nginx]

  triggers_replace = plantimestamp()

  provisioner "local-exec" {
    command = "KUBECONFIG='.kube/config' cat <<EOF | kubectl apply -f -\nkind: ConfigMap\nmetadata:\n  name: coredns\n  namespace: kube-system\napiVersion: v1\ndata:\n  Corefile: |\n    .:53 {\n        errors\n        health {\n           lameduck 5s\n        }\n        ready\n        kubernetes cluster.local in-addr.arpa ip6.arpa {\n           pods insecure\n           fallthrough in-addr.arpa ip6.arpa\n           ttl 30\n        }\n        prometheus :9153\n        forward . 1.1.1.1\n        cache 30\n        loop\n        reload\n        loadbalance\n    }\n    osiks.local {\n       hosts {\n         $(kubectl get svc ingress-nginx-controller --no-headers -n ingress-nginx | awk '{print$3}') osiks.local\n         fallthrough\n       }\n       whoami\n    }\nEOF"
  }
}
