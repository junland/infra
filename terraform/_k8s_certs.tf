# Create cert-manager namespace
resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

# Create Cloudflare API token secret for cert-manager
resource "kubernetes_secret_v1" "cloudflare_api_token" {
  metadata {
    name      = "cloudflare-api-token-secret"
    namespace = kubernetes_namespace_v1.cert_manager.metadata[0].name
  }

  data = {
    api-token = sensitive(var.cf_api_token)
  }

  type = "Opaque"
}

# Install cert-manager helm chart
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace_v1.cert_manager.metadata[0].name
  replace    = true
  atomic     = true

  set = [{
    name  = "installCRDs"
    value = "true"
  }]

  depends_on = [kubernetes_namespace_v1.cert_manager]
}

resource "helm_release" "cert_manager_cluster_issuer" {
  name       = "cert-manager-cluster-issuer"
  repository = "https://bedag.github.io/helm-charts/"
  chart      = "raw"
  namespace  = kubernetes_namespace_v1.cert_manager.metadata[0].name
  version    = "2.0.2"
  replace    = true
  atomic     = true

  values = [
    yamlencode({
      resources = [
        {
          apiVersion = "cert-manager.io/v1"
          kind       = "ClusterIssuer"
          metadata = {
            name = local.wildcard_cluster_issuer_name
          }
          spec = {
            acme = {
              server = "https://acme-v02.api.letsencrypt.org/directory"
              email  = var.k3s_cert_manager_email
              privateKeySecretRef = {
                name = local.wildcard_cluster_issuer_name
              }
              solvers = [
                {
                  dns01 = {
                    cloudflare = {
                      apiTokenSecretRef = {
                        name = kubernetes_secret_v1.cloudflare_api_token.metadata[0].name
                        key  = "api-token"
                      }
                    }
                  }
                  selector = {
                    dnsZones = [var.k3s_cert_manager_domain, local.wildcard_host]
                  }
                }
              ]
            }
          }
        },
        {
          apiVersion = "cert-manager.io/v1"
          kind       = "Certificate"
          metadata = {
            name      = local.wildcard_secret_name
            namespace = kubernetes_namespace_v1.cert_manager.metadata[0].name
          }
          spec = {
            dnsNames = [
              local.wildcard_host
            ]
            issuerRef = {
              name = local.wildcard_cluster_issuer_name
              kind = "ClusterIssuer"
            }
            secretName = local.wildcard_secret_name
            commonName = local.wildcard_host
            dnsNames = [
              local.wildcard_host
            ]
          }
        }
      ]
    })
  ]

  depends_on = [helm_release.cert_manager]
}


