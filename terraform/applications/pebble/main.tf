provider "helm" {
  kubernetes {
    config_path = "../../.kube/config"
  }
}

resource "helm_release" "pebble" {
  name = "pebble"

  repository       = "https://jupyterhub.github.io/helm-chart"
  chart            = "pebble"
  namespace        = "pebble"
  create_namespace = true
  version          = "1.1.0"

  values = [file("pebble-values.yaml")]
}
