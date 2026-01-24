resource "kubernetes_namespace_v1" "test" {
  metadata {
    name = "nginx"
  }
}

# Deployment for blue
resource "kubernetes_deployment" "test_app_blue" {
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

# Service for blue
resource "kubernetes_service" "svc_blue" {
  metadata {
    name = "svc-blue"
    labels = {
      color = "blue"
    }
  }

  spec {
    selector = {
      app   = "test-app"
      color = "blue"
    }

    port {
      port        = 80
      protocol    = "TCP"
      target_port = 8080
    }
  }
}

# Ingress for blue
resource "kubernetes_ingress_v1" "lb_ingress_blue" {
  metadata {
    name = "lb-ingress-blue"
  }

  spec {
    ingress_class_name = "haproxy"

    rule {
      host = "blue.local"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.svc_blue.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
