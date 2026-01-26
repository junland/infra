resource "kubernetes_deployment_v1" "test_app_blue" {
  metadata {
    name = "test-app-blue"
    labels = {
      app   = "test-app"
      color = "blue"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app   = "test-app"
        color = "blue"
      }
    }

    template {
      metadata {
        labels = {
          app   = "test-app"
          color = "blue"
        }
      }

      spec {
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "kubernetes.io/os"
                  operator = "In"
                  values   = ["linux"]
                }
              }
            }
          }
        }

        container {
          name  = "test-blue"
          image = "docker.io/kirbah/blue-green:blue"

          port {
            container_port = 8080
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "test_app_blue" {
  metadata {
    name = "svc-blue"

    labels = {
      color = "blue"
    }
  }

  spec {
    port {
      port        = 80
      protocol    = "TCP"
      target_port = 8080
    }

    selector = {
      app   = "test-app"
      color = "blue"
    }
  }
}

resource "kubernetes_ingress_v1" "test_app_blue" {
  metadata {
    name = "lb-ingress-blue"

    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "haproxy"

    rule {
      host = "blue.${var.cert_manager_domain}"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "svc-blue"
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    rule {
      host = "blue.local"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "svc-blue"
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    tls {
      hosts       = ["blue.${var.cert_manager_domain}"]
      secret_name = "blue-tls-secret"
    }
  }

}
