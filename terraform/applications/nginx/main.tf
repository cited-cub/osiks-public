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

#resource "kubernetes_manifest" "pebble_issuer" {
#  depends_on = [kubernetes_namespace.nginx]
#
#  manifest = provider::kubernetes::manifest_decode(file("./applications/nginx/pebble_issuer.yaml"))
#}

locals {
  resources = provider::kubernetes::manifest_decode_multi(file("./nginx.yaml"))
  #resources = provider::kubernetes::manifest_decode_multi(file("./applications/nginx/nginx.yaml"))
}

resource "kubernetes_manifest" "nginx" {
#  depends_on = [kubernetes_manifest.pebble_issuer]
  depends_on = [kubernetes_namespace.nginx]

  for_each = {
    for manifest in local.resources :
    "${manifest.kind}--${manifest.metadata.name}" => manifest
  }

  manifest = each.value
}

#resource "terraform_data" "patch_coredns" {
#  triggers_replace = plantimestamp()
#
#  provisioner "local-exec" {
#    command = "cat <<EOF | kubectl apply -f -\nkind: ConfigMap\nmetadata:\n  name: coredns\n  namespace: kube-system\napiVersion: v1\ndata:\n  Corefile: |\n    .:53 {\n        errors\n        health {\n           lameduck 5s\n        }\n        ready\n        kubernetes cluster.local in-addr.arpa ip6.arpa {\n           pods insecure\n           fallthrough in-addr.arpa ip6.arpa\n           ttl 30\n        }\n        prometheus :9153\n        forward . 1.1.1.1\n        cache 30\n        loop\n        reload\n        loadbalance\n    }\n    osiks.local {\n       hosts {\n         $(kubectl get svc ingress-nginx-controller --no-headers -n ingress-nginx | awk '{print$3}') osiks.local\n         fallthrough\n       }\n       whoami\n    }\nEOF"
#  }
#}
