resource "kubernetes_namespace_v1" "argocd_system" {
  metadata {
    name = "argocd-system"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace_v1.argocd_system.metadata[0].name
  replace    = true
  atomic     = true

  values = [
    yamlencode({
      global = {
        domain = "argocd.${var.k3s_cert_manager_domain}"
      }
      certificate = {
        enabled = true
      }
      server = {
        ingress = {
          enabled          = true
          ingressClassName = "haproxy"
          hosts            = ["argocd.${var.k3s_cert_manager_domain}"]
          annotations = {
            "cert-manager.io/cluster-issuer" = local.wildcard_cluster_issuer_name
            "haproxy.org/ingress.class"      = "haproxy"
            "haproxy.org/ssl-passthrough"    = "true"
            "haproxy.org/ssl-redirect-code"  = "301"
            "haproxy.org/ssl-redirect-port"  = "443"
          }
          tls = [
            {
              secretName = local.wildcard_secret_name
              hosts      = [local.wildcard_host]
            }
          ]
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace_v1.argocd_system, helm_release.ingress]
}
