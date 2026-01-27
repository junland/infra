resource "kubernetes_deployment_v1" "test_app_green" {
  metadata {
    name = "test-app-green"

    labels = {
      app   = "test-app"
      color = "green"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        color = "green"
      }
    }

    template {
      metadata {
        labels = {
          app   = "test-app"
          color = "green"
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
          name  = "test-green"
          image = "docker.io/kirbah/blue-green:green"

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

resource "kubernetes_service_v1" "test_app_green" {
  metadata {
    name = "svc-green"

    labels = {
      color = "green"
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
      color = "green"
    }
  }
}

resource "kubernetes_ingress_v1" "test_app_green" {
  metadata {
    name = "lb-ingress-green"

    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-dns"
    }
  }

  spec {
    ingress_class_name = "haproxy"

    rule {
      host = "green.${var.cert_manager_domain}"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "svc-green"
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    tls {
      hosts       = ["*.${var.cert_manager_domain}"]
      secret_name = "wildcard-cert"
    }
  }
}
