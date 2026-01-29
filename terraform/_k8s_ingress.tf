resource "kubernetes_namespace_v1" "ingress_system" {
  metadata {
    name = "ingress-system"
  }
}

resource "helm_release" "ingress" {
  name       = "haproxy-ingress-controller"
  repository = "https://haproxytech.github.io/helm-charts"
  chart      = "kubernetes-ingress"
  namespace  = kubernetes_namespace_v1.ingress_system.metadata[0].name
  replace    = true

  set = [
    {
      name  = "controller.service.type"
      value = "LoadBalancer"
    },
    {
      name  = "controller.daemonset.useHostPort"
      value = "true"
    },
    {
      name  = "controller.service.loadBalancerIP"
      value = var.k3s_loadbalancer_ip
    },
    {
      name  = "controller.logging.traffic.address"
      value = "stdout"
    },
    {
      name  = "controller.logging.traffic.format"
      value = "raw"
    },
    {
      name  = "controller.logging.traffic.facility"
      value = "daemon"
    }
  ]

  depends_on = [kubernetes_namespace_v1.ingress_system, helm_release.loadbalancer]
}
