provider "kubectl" {
  config_path = "../../.kube/config"
}
provider "helm" {
  kubernetes {
    config_path = "../../.kube/config"
  }
}
provider "kubernetes" {
  config_path = "../../.kube/config"
}
terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.28.0"
    }
  }
}

#provider "helm" {
#  kubernetes {
#    config_path = "../.././kube/config"
#  }
#}

#resource "helm_release" "cert-manager" {
#  name = "cert-manager"
#
#  repository       = "https://charts.jetstack.io"
#  chart            = "cert-manager"
#  namespace        = "cert-manager"
#  create_namespace = true
#  version          = "v1.15.1"
#
#  set {
#    name = "crds.enabled"
#    value = "true"
#  }
#}

module "cert-manager" {
  source = "terraform-iaac/cert-manager/kubernetes"

  cluster_issuer_email = "admin@mysite.com"
#  cluster_issuer_name = "pebble"
#  cluster_issuer_private_key_secret_name = "cert-manager-private-key"
#  cluster_issuer_server = "https://pebble.pebble/dir"
  cluster_issuer_yaml = "apiVersion: cert-manager.io/v1\nkind: ClusterIssuer\nmetadata:\n  name: pebble\nspec:\n  acme:\n    email: admin@mysite.com\n    preferredChain: ISRG Root X1\n    privateKeySecretRef:\n      name: cert-manager-private-key\n    server: https://pebble.pebble/dir\n    caBundle: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURnVENDQW1tZ0F3SUJBZ0lJQWZtc3lFZ2g3M013RFFZSktvWklodmNOQVFFTEJRQXdJREVlTUJ3R0ExVUUKQXhNVmJXbHVhV05oSUhKdmIzUWdZMkVnTTJGbU5EZGlNQ0FYRFRJME1EY3hOREV6TWprek5Gb1lEekl4TVRRdwpOekUwTVRNeU9UTTBXakFVTVJJd0VBWURWUVFERXdsc2IyTmhiR2h2YzNRd2dnRWlNQTBHQ1NxR1NJYjNEUUVCCkFRVUFBNElCRHdBd2dnRUtBb0lCQVFDK1U3K2lyN3lWcytTUzhKandDRCswOVhORk1IbGUzam9leC9Qck9hK3IKUXlkeG9aWVFtb2ljdktTTXlJSjJTZzdHZjdFSDRFYklhNFEyVU1VZjRQSExodHhwa1UvNUZQTUlTK1BhclZiSgp4WmdEUDF2OElCdU9ZRmNDcWppcmhpS3hCY3FsUEdiRG9wVXRYd1lhOFYreDlBQUttUjh5dEZKQ0UwWXFoZ3cyCkUyUUp2bEhqRUIvTDVnKzN5QlFkcXpneXduSFBIMEluRW9ETGxBNUc5a05GVWZzeUZUckJ2SFVrVmpwd1I5RmoKZ3ZDTEVKMmpNUWtwMytHbjVqcjRDYWFsdUtYMDFXQWo2Wldod29YcENNN3V6M2V1OURQSkwvcUVOTWtrVXJtcAo1SHhMWU1SeGpsSUpVOWdYQU4xREI1dnBFSlVVLzhhOVNQbWJtbWgrZ0NpSEFnTUJBQUdqZ2Nnd2djVXdEZ1lEClZSMFBBUUgvQkFRREFnV2dNQjBHQTFVZEpRUVdNQlFHQ0NzR0FRVUZCd01CQmdnckJnRUZCUWNEQWpBTUJnTlYKSFJNQkFmOEVBakFBTUI4R0ExVWRJd1FZTUJhQUZIUXlCNXcxN2hGam52bW9DMGkzck1DTnNHb3RNR1VHQTFVZApFUVJlTUZ5Q0NXeHZZMkZzYUc5emRJSUdjR1ZpWW14bGdnMXdaV0ppYkdVdWNHVmlZbXhsZ2hGd1pXSmliR1V1CmNHVmlZbXhsTG5OMlk0SWZjR1ZpWW14bExuQmxZbUpzWlM1emRtTXVZMngxYzNSbGNpNXNiMk5oYkljRWZ3QUEKQVRBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQVFFQWdaRFpIMzFHWlVtQTFLRTlDSWFZcUNUcEZaN1JVRUl5ODl0Tgprc2tLQzJ0dTh4VHRoem83MjdVNmJpQzcramtEdmZmZVVTMU9pdnZpS01WanlXSjBKMmhRd0pTa2lMK2E5YnFlCjZJUjNiWHhjWVhQYWpVcTBjOThmR2FlZnB1SzV1ZE5wM3NSS3VaOTdzSDVxbjROdUJwYXJyQmI1M3R4aGV1dlcKYWZlK1FBVG5SaHI2TFk0UGxmcm9yMXAzdWdhaGw4VDRBZFdBYXdTSjZ1REc4dlNPbFJ3bHlJQkYyendRV0xtaQpzZzVDTWF3ZmI1dzJCZkRyNDhmcVhJUEhOMTQ0N2x0VExxdFZ3OFl4WUtKSjNEQ0drNzR6a1pnR0g0OHhvRWlaCmlqOUs5RUdnMnRUa1FQMFFuRGwydDEzbUdzemZZWUZiRVF6cFFCb0c1N3N5TlU1M21RPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=\n    solvers:\n    - http01:\n        ingress:\n          class: nginx"
#  solvers = [
#    {
#      http01 = {
#        ingress = {
#          class = "nginx"
#        }
#      }
#    }
#  ]
}
