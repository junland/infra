resource "helm_release" "haproxy_ingress" {
  name       = "haproxy-kubernetes-ingress"
  repository = "https://haproxytech.github.io/helm-charts"
  chart      = "haproxy-ingress-controller"
}


