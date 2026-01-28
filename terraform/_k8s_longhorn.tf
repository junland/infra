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
        tls              = true
        tlsSecretName    = local.wildcard_secret_name
        annotations = {
          "cert-manager.io/cluster-issuer"    = local.wildcard_cluster_issuer_name
          "ingress.kubernetes.io/auth-type"   = "basic-auth"
          "ingress.kubernetes.io/auth-secret" = "basic-auth"
          "ingress.kubernetes.io/auth-realm"  = "Authentication Required"
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.longhorn_system
  ]
}
