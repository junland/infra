resource "kubernetes_namespace_v1" "longhorn_system" {
  count = var.k8s_longhorn_install ? 1 : 0

  metadata {
    name = "longhorn-system"
  }
}

resource "helm_release" "longhorn" {
  count = var.k8s_longhorn_install ? 1 : 0

  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  namespace  = kubernetes_namespace_v1.longhorn_system[0].metadata[0].name
  replace    = true
  atomic     = true

  set = [{
    name  = "persistence.defaultFsType"
    value = "xfs"
  }]

  values = [
    yamlencode({
      ingress = {
        enabled          = true
        apiVersion       = "networking.k8s.io/v1"
        ingressClassName = "haproxy"
        host             = "longhorn.${var.k8s_cert_manager_domain}"
        pathType         = "Prefix"
        path             = "/"
        annotations = {
          "haproxy.org/ingress.class" = "haproxy"
          "haproxy.org/auth-type"     = "basic-auth"
          "haproxy.org/auth-secret"   = "longhorn-basic-auth"
          "haproxy.org/auth-realm"    = "Restricted Area"
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.longhorn_system[0], helm_release.loadbalancer_crds
  ]
}

resource "kubernetes_secret_v1" "longhorn_basic_auth" {
  count = var.k8s_longhorn_install ? 1 : 0

  metadata {
    name      = "longhorn-basic-auth"
    namespace = kubernetes_namespace_v1.longhorn_system[0].metadata[0].name
  }

  data = {
    "${var.k8s_longhorn_admin_username}" = sensitive(var.k8s_longhorn_admin_password)
  }

  type = "Opaque"
}
