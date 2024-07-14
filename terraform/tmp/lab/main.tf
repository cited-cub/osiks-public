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

resource "terraform_data" "patch_coredns" {
  triggers_replace = plantimestamp()

  provisioner "local-exec" {
    command = "cat <<EOF > test-cm.yaml
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . 1.1.1.1
        cache 30
        loop
        reload
        loadbalance
    }
    example.example.com {
       hosts {
         $(kubectl get svc ingress-nginx-controller --no-headers -n ingress-nginx | awk '{print$3}') example.example.com
         fallthrough
       }
       whoami
    }
EOF"
  }
}
