resource "kubernetes_namespace_v1" "longhorn_system" {
  metadata {
    name = "longhorn-system"
  }
}

resource "helm_release" "longhorn" {
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  namespace  = kubernetes_namespace_v1.longhorn_system.metadata[0].name
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
        host             = "longhorn.${var.k3s_cert_manager_domain}"
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
    kubernetes_namespace_v1.longhorn_system, helm_release.loadbalancer_crds
  ]
}

resource "kubernetes_secret_v1" "longhorn_basic_auth" {
  metadata {
    name      = "longhorn-basic-auth"
    namespace = kubernetes_namespace_v1.longhorn_system.metadata[0].name
  }

  data = {
    "${var.k3s_longhorn_admin_username}" = sensitive(var.k3s_longhorn_admin_password)
  }

  type = "Opaque"
}
