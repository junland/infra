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

  set = [{
    name  = "persistence.defaultFsType"
    value = "xfs"
  }]

  depends_on = [kubernetes_namespace_v1.longhorn_system]
}
