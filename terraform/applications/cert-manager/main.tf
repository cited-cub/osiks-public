provider "helm" {
  kubernetes {
    config_path = "../../.kube/config"
  }
}

resource "helm_release" "cert-manager" {
  name = "cert-manager"

  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.15.1"

  set {
    name = "crds.enabled"
    value = "true"
  }
}
