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

  set = [
    {
      name  = "server.ingress.enabled"
      value = "true"
    },
    {
      name  = "server.ingress.ingressClassName"
      value = "haproxy"
    },
    {
      name  = "server.ingress.hosts[0]"
      value = "argocd.${var.k3s_cert_manager_domain}"
    },
    {
      name  = "haproxy.org//cluster-issuer"
      value = local.wildcard_cluster_issuer_name
    },
    {
      name  = "server.ingress.annotations.haproxy.org/ingress.class"
      value = "haproxy"
    },
    {
      name  = "server.ingress.annotations.haproxy.org/force-ssl-redirect"
      value = "true"
    },
    {
      name  = "extraTls[0].hosts[0]"
      value = "argocd.${var.k3s_cert_manager_domain}"
    },
    {
      name  = "extraTls[0].secretName"
      value = local.wildcard_secret_name
    }
  ]

  depends_on = [kubernetes_namespace_v1.argocd_system, helm_release.ingress]
}
