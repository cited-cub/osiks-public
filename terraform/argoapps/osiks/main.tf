provider "kubernetes" {
  config_path = "../../.kube/config"
}

resource "kubernetes_manifest" "osiks-public_argoproj" {
  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "AppProject"
    "metadata" = {
      "name"      = "osiks-public"
      "namespace" = "argocd"
    }
    "spec" = {
      "clusterResourceWhitelist" = [
        {
          "group" = "*"
          "kind"  = "*"
        },
      ]
      "destinations" = [
        {
          "name"      = "*"
          "namespace" = "*"
          "server"    = "*"
        },
      ]
      "namespaceResourceWhitelist" = [
        {
          "group" = "*"
          "kind"  = "*"
        },
      ]
      "sourceRepos" = [
        "*",
      ]
    }
  }
}

resource "kubernetes_manifest" "osiks_argoapp" {
  depends_on = [kubernetes_manifest.osiks-public_argoproj]

  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "osiks-nginx"
      "namespace" = "argocd"
    }
    "spec" = {
      "destination" = {
        "namespace" = "osiks-nginx"
        "server"    = "https://kubernetes.default.svc"
      }
      "project" = "osiks-public"
      "source" = {
        "path"           = "applications/osiks"
        "repoURL"        = "https://github.com/cited-cub/osiks-public.git"
        "targetRevision" = "HEAD"
      }
    }
  }
}

