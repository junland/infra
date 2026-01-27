resource "kubernetes_namespace_v1" "loadbalancer_system" {
  metadata {
    name = "loadbalancer-system"
  }
}

resource "helm_release" "loadbalancer" {
  name       = "loadbalancer-controller"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  namespace  = kubernetes_namespace_v1.loadbalancer_system.metadata[0].name

  depends_on = [kubernetes_namespace_v1.loadbalancer_system]
}

resource "helm_release" "loadbalancer_crds" {
  name       = "loadbalancer-crds"
  repository = "https://bedag.github.io/helm-charts/"
  chart      = "raw"
  namespace  = kubernetes_namespace_v1.loadbalancer_system.metadata[0].name
  replace    = true
  version    = "2.0.2"

  values = [
    yamlencode({
      resources = [{
        apiVersion = "metallb.io/v1beta1"
        kind       = "IPAddressPool"
        metadata = {
          name      = "primary"
          namespace = kubernetes_namespace_v1.loadbalancer_system.metadata[0].name
        }
        spec = {
          addresses = [var.k3s_loadbalancer_pool]
        }
        },
        {
          apiVersion = "metallb.io/v1beta1"
          kind       = "L2Advertisement"
          metadata = {
            name      = "l2-advertisement"
            namespace = kubernetes_namespace_v1.loadbalancer_system.metadata[0].name
          }
          spec = {
            ipAddressPools = ["primary"]
          }
      }]
    })
  ]

  depends_on = [helm_release.loadbalancer, kubernetes_namespace_v1.loadbalancer_system]
}
