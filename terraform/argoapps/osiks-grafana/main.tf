provider "kubernetes" {
  config_path = "../../.kube/config"
}

resource "kubernetes_manifest" "osiks-grafana_argoapp" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "osiks-grafana"
      "namespace" = "argocd"
    }
    "spec" = {
      "destination" = {
        "namespace" = "osiks-grafana"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "osiks-public"
      "source" = {
        "path"           = "applications/osiks-grafana"
        "repoURL"        = "https://github.com/cited-cub/osiks-public.git"
        "targetRevision" = "HEAD"
      }
    }
  }
}
