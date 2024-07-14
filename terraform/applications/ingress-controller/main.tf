#terraform {
#  required_version = ">= 1.8.0"
#
#  required_providers {
#    kubernetes = {
#      source  = "hashicorp/kubernetes"
#      version = ">= 2.28.0"
#    }
#  }
#}
#
#provider "helm" {
#  kubernetes {
#    config_path = "../../.kube/config"
#  }
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

#provider "kubernetes" {
#  config_path = "../../.kube/config"
#}

#resource "kubernetes_namespace" "ingress-nginx" {
#  metadata {
#    labels = {
#      "app.kubernetes.io/instance" = "ingress-nginx"
#      "app.kubernetes.io/name"     = "ingress-nginx"
#    }
#    name = "ingress-nginx"
#  }
#}
#
#locals {
#  resources = provider::kubernetes::manifest_decode_multi(file("ingress_controller.yaml"))
#}
#
#resource "kubernetes_manifest" "ingress_controller" {
#  depends_on = [kubernetes_namespace.ingress-nginx]
#
#  for_each = {
#    for manifest in local.resources :
#    "${manifest.kind}--${manifest.metadata.name}" => manifest
#  }
#
#  manifest = each.value
#}
#
##resource "kubernetes_manifest" "ingress-nginx-controller_deployment" {
##  depends_on = [kubernetes_manifest.ingress_controller]
##
##  manifest = provider::kubernetes::manifest_decode(file("manifests/ingress-nginx-controller_deployment.yaml"))
##}
#
#resource "kubernetes_deployment" "ingress-nginx-controller_deployment" {
#  metadata {
#    labels = {
#      "app.kubernetes.io/component" = "controller"
#      "app.kubernetes.io/instance"  = "ingress-nginx"
#      "app.kubernetes.io/name"      = "ingress-nginx"
#      "app.kubernetes.io/part-of"   = "ingress-nginx"
#      "app.kubernetes.io/version"   = "1.10.1"
#    }
#    name      = "ingress-nginx-controller"
#    namespace = "ingress-nginx"
#  }
#  spec {
#    min_ready_seconds      = 0
#    revision_history_limit = 10
#    selector {
#      match_labels = {
#        "app.kubernetes.io/component" = "controller"
#        "app.kubernetes.io/instance"  = "ingress-nginx"
#        "app.kubernetes.io/name"      = "ingress-nginx"
#      }
#    }
#    strategy {
#      rolling_update {
#        max_unavailable = 1
#      }
#      type = "RollingUpdate"
#    }
#    template {
#      metadata {
#        labels = {
#          "app.kubernetes.io/component" = "controller"
#          "app.kubernetes.io/instance"  = "ingress-nginx"
#          "app.kubernetes.io/name"      = "ingress-nginx"
#          "app.kubernetes.io/part-of"   = "ingress-nginx"
#          "app.kubernetes.io/version"   = "1.10.1"
#        }
#      }
#      spec {
#        container {
#          args = [
#            "/nginx-ingress-controller",
#            "--election-id=ingress-nginx-leader",
#            "--controller-class=k8s.io/ingress-nginx",
#            "--ingress-class=nginx",
#            "--configmap=$(POD_NAMESPACE)/ingress-nginx-controller",
#            "--validating-webhook=:8443",
#            "--validating-webhook-certificate=/usr/local/certificates/cert",
#            "--validating-webhook-key=/usr/local/certificates/key",
#            "--watch-ingress-without-class=true",
#            "--enable-metrics=false",
#            "--publish-status-address=localhost",
#          ]
#          env {
#            name = "POD_NAME"
#            value_from {
#              field_ref {
#                field_path = "metadata.name"
#              }
#            }
#          }
#          env {
#            name = "POD_NAMESPACE"
#            value_from {
#              field_ref {
#                field_path = "metadata.namespace"
#              }
#            }
#          }
#          env {
#            name  = "LD_PRELOAD"
#            value = "/usr/local/lib/libmimalloc.so"
#          }
#          image             = "registry.k8s.io/ingress-nginx/controller:v1.10.1@sha256:e24f39d3eed6bcc239a56f20098878845f62baa34b9f2be2fd2c38ce9fb0f29e"
#          image_pull_policy = "IfNotPresent"
#          lifecycle {
#            pre_stop {
#              exec {
#                command = [
#                  "/wait-shutdown",
#                ]
#              }
#            }
#          }
#          liveness_probe {
#            failure_threshold = 5
#            http_get {
#              path   = "/healthz"
#              port   = 10254
#              scheme = "HTTP"
#            }
#            initial_delay_seconds = 10
#            period_seconds        = 10
#            success_threshold     = 1
#            timeout_seconds       = 1
#          }
#          name = "controller"
#          port {
#            container_port = 80
#            host_port      = 80
#            name           = "http"
#            protocol       = "TCP"
#          }
#          port {
#            container_port = 443
#            host_port      = 443
#            name           = "https"
#            protocol       = "TCP"
#          }
#          port {
#            container_port = 8443
#            name           = "webhook"
#            protocol       = "TCP"
#          }
#          readiness_probe {
#            failure_threshold = 3
#            http_get {
#              path   = "/healthz"
#              port   = 10254
#              scheme = "HTTP"
#            }
#            initial_delay_seconds = 10
#            period_seconds        = 10
#            success_threshold     = 1
#            timeout_seconds       = 1
#          }
#          resources {
#            requests = {
#              cpu    = "100m"
#              memory = "90Mi"
#            }
#          }
#          security_context {
#            allow_privilege_escalation = false
#            capabilities {
#              add = [
#                "NET_BIND_SERVICE",
#              ]
#              drop = [
#                "ALL",
#              ]
#            }
#            read_only_root_filesystem = false
#            run_as_non_root           = true
#            run_as_user               = 101
#            seccomp_profile {
#              type = "RuntimeDefault"
#            }
#          }
#          volume_mount {
#            mount_path = "/usr/local/certificates/"
#            name       = "webhook-cert"
#            read_only  = true
#          }
#        }
#        dns_policy = "ClusterFirst"
#        node_selector = {
#          ingress-ready      = "true"
#          "kubernetes.io/os" = "linux"
#        }
#        service_account_name             = "ingress-nginx"
#        termination_grace_period_seconds = 0
#        toleration {
#          effect   = "NoSchedule"
#          key      = "node-role.kubernetes.io/master"
#          operator = "Equal"
#        }
#        toleration {
#          effect   = "NoSchedule"
#          key      = "node-role.kubernetes.io/control-plane"
#          operator = "Equal"
#        }
#        volume {
#          name = "webhook-cert"
#          secret {
#            secret_name = "ingress-nginx-admission"
#          }
#        }
#      }
#    }
#  }
#}
#
##resource "kubernetes_deployment" "ingress-nginx-controller_deployment" {
##  metadata {
##    labels = {
##      app.kubernetes.io/component = "controller"
##      app.kubernetes.io/instance = "ingress-nginx"
##      app.kubernetes.io/name = "ingress-nginx"
##      app.kubernetes.io/part-of = "ingress-nginx"
##      app.kubernetes.io/version = "1.10.1"
##
##    }
##    name: ingress-nginx-controller
##  spec {
##    min_ready_seconds = 0
##    revision_history_limit = 10
##    selector {
##      match_labels = {
##        app.kubernetes.io/component = "controller"
##        app.kubernetes.io/instance = "ingress-nginx"
##        app.kubernetes.io/name = "ingress-nginx"
##      }
##    }
##    strategy {
##      rolling_update {
##        max_unavailable = 1
##      }
##      type = "RollingUpdate"
##    }
##    template {
##      metadata {
##        labels = {
##          app.kubernetes.io/component = "controller"
##          app.kubernetes.io/instance = "ingress-nginx"
##          app.kubernetes.io/name = "ingress-nginx"
##          app.kubernetes.io/part-of = "ingress-nginx"
##          app.kubernetes.io/version = "1.10.1"
##        }        
##      }
##      spec {
##        container {
##          args [
##            "/nginx-ingress-controller",
##            "--election-id=ingress-nginx-leader",
##            "--controller-class=k8s.io/ingress-nginx",
##            "--ingress-class=nginx",
##            "--configmap=$(POD_NAMESPACE)/ingress-nginx-controller",
##            "--validating-webhook=:8443",
##            "--validating-webhook-certificate=/usr/local/certificates/cert",
##            "--validating-webhook-key=/usr/local/certificates/key",
##            "--watch-ingress-without-class=true",
##            "--enable-meetrics=false",
##            "--publish-status-address=localhost"
##          ]
##          env {
##            name = "POD_NAME"
##            value_from {
##              field_ref {
##                field_path = metadata.name
##              }
##            }
##          }
##          env {
##            name = "POD_NAMESPACE"
##            value_from {
##              field_ref {
##                field_path = metadata.namespace
##              }
##            }
##          }
##          env {
##            name = "LD_PRELOAD"
##            value = /usr/local/lib/libmimalloc.so"
##          }
##          image = "registry.k8s.io/ingress-nginx/controller:v1.10.1@sha256:e24f39d3eed6bcc239a56f20098878845f62baa34b9f2be2fd2c38ce9fb0f29e"
##    }
##  }
##}
#
#resource "kubernetes_job" "ingress-nginx-admission-create" {
#  metadata {
#    labels = {
#      "app.kubernetes.io/component" = "admission-webhook"
#      "app.kubernetes.io/instance"  = "ingress-nginx"
#      "app.kubernetes.io/name"      = "ingress-nginx"
#      "app.kubernetes.io/part-of"   = "ingress-nginx"
#      "app.kubernetes.io/version"   = "1.10.1"
#    }
#    name      = "ingress-nginx-admission-create"
#    namespace = "ingress-nginx"
#  }
#  spec {
#    template {
#      metadata {
#        labels = {
#          "app.kubernetes.io/component" = "admission-webhook"
#          "app.kubernetes.io/instance"  = "ingress-nginx"
#          "app.kubernetes.io/name"      = "ingress-nginx"
#          "app.kubernetes.io/part-of"   = "ingress-nginx"
#          "app.kubernetes.io/version"   = "1.10.1"
#        }
#        name = "ingress-nginx-admission-create"
#      }
#      spec {
#        container {
#          args = [
#            "create",
#            "--host=ingress-nginx-controller-admission,ingress-nginx-controller-admission.$(POD_NAMESPACE).svc",
#            "--namespace=$(POD_NAMESPACE)",
#            "--secret-name=ingress-nginx-admission",
#          ]
#          env {
#            name = "POD_NAMESPACE"
#            value_from {
#              field_ref {
#                field_path = "metadata.namespace"
#              }
#            }
#          }
#          image             = "registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.1@sha256:36d05b4077fb8e3d13663702fa337f124675ba8667cbd949c03a8e8ea6fa4366"
#          image_pull_policy = "IfNotPresent"
#          name              = "create"
#          security_context {
#            allow_privilege_escalation = false
#            capabilities {
#              drop = [
#                "ALL"
#              ]
#            }
#            read_only_root_filesystem = true
#            run_as_non_root           = true
#            run_as_user               = 65532
#            seccomp_profile {
#              type = "RuntimeDefault"
#            }
#          }
#        }
#        node_selector = {
#          "kubernetes.io/os" = "linux"
#        }
#        restart_policy       = "OnFailure"
#        service_account_name = "ingress-nginx-admission"
#      }
#    }
#  }
#}
#
#resource "kubernetes_job" "ingress-nginx-admission-patch" {
#  metadata {
#    labels = {
#      "app.kubernetes.io/component" = "admission-webhook"
#      "app.kubernetes.io/instance"  = "ingress-nginx"
#      "app.kubernetes.io/name"      = "ingress-nginx"
#      "app.kubernetes.io/part-of"   = "ingress-nginx"
#      "app.kubernetes.io/version"   = "1.10.1"
#    }
#    name      = "ingress-nginx-admission-patch"
#    namespace = "ingress-nginx"
#  }
#  spec {
#    template {
#      metadata {
#        labels = {
#          "app.kubernetes.io/component" = "admission-webhook"
#          "app.kubernetes.io/instance"  = "ingress-nginx"
#          "app.kubernetes.io/name"      = "ingress-nginx"
#          "app.kubernetes.io/part-of"   = "ingress-nginx"
#          "app.kubernetes.io/version"   = "1.10.1"
#        }
#        name = "ingress-nginx-admission-patch"
#      }
#      spec {
#        container {
#          args = [
#            "patch",
#            "--webhook-name=ingress-nginx-admission",
#            "--namespace=$(POD_NAMESPACE)",
#            "--patch-mutating=false",
#            "--secret-name=ingress-nginx-admission",
#            "--patch-failure-policy=Fail"
#          ]
#          env {
#            name = "POD_NAMESPACE"
#            value_from {
#              field_ref {
#                field_path = "metadata.namespace"
#              }
#            }
#          }
#          image             = "registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.1@sha256:36d05b4077fb8e3d13663702fa337f124675ba8667cbd949c03a8e8ea6fa4366"
#          image_pull_policy = "IfNotPresent"
#          name              = "patcpatchh"
#          security_context {
#            allow_privilege_escalation = false
#            capabilities {
#              drop = [
#                "ALL"
#              ]
#            }
#            read_only_root_filesystem = true
#            run_as_non_root           = true
#            run_as_user               = 65532
#            seccomp_profile {
#              type = "RuntimeDefault"
#            }
#          }
#        }
#        node_selector = {
#          "kubernetes.io/os" = "linux"
#        }
#        restart_policy       = "OnFailure"
#        service_account_name = "ingress-nginx-admission"
#      }
#    }
#  }
#}
