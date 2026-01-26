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
    api-token = var.cf_api_token
  }

  type = "Opaque"

  depends_on = [kubernetes_namespace_v1.cert_manager]
}

# Install cert-manager helm chart
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace_v1.cert_manager.metadata[0].name
  version    = "v1.14.0"

  set {
    name  = "installCRDs"
    value = "true"
  }

  depends_on = [kubernetes_namespace_v1.cert_manager]
}

# Create ClusterIssuer for Let's Encrypt with Cloudflare DNS01 challenge
resource "helm_release" "cert_manager_cluster_issuer" {
  name       = "cert-manager-cluster-issuer"
  repository = "https://bedag.github.io/helm-charts/"
  chart      = "raw"
  namespace  = kubernetes_namespace_v1.cert_manager.metadata[0].name
  replace    = true

  values = [
    yamlencode({
      resources = [
        {
          apiVersion = "cert-manager.io/v1"
          kind       = "ClusterIssuer"
          metadata = {
            name = "letsencrypt-prod"
          }
          spec = {
            acme = {
              server = "https://acme-v02.api.letsencrypt.org/directory"
              email  = var.cert_manager_email
              privateKeySecretRef = {
                name = "letsencrypt-prod-account-key"
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
                    dnsZones = [var.primary_zone_name]
                  }
                }
              ]
            }
          }
        },
        {
          apiVersion = "cert-manager.io/v1"
          kind       = "ClusterIssuer"
          metadata = {
            name = "letsencrypt-staging"
          }
          spec = {
            acme = {
              server = "https://acme-staging-v02.api.letsencrypt.org/directory"
              email  = var.cert_manager_email
              privateKeySecretRef = {
                name = "letsencrypt-staging-account-key"
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
                    dnsZones = [var.primary_zone_name]
                  }
                }
              ]
            }
          }
        }
      ]
    })
  ]

  depends_on = [helm_release.cert_manager, kubernetes_secret_v1.cloudflare_api_token]
}

# Example Certificate resource for wildcard domain
# Uncomment and customize this resource to issue wildcard certificates
# resource "helm_release" "cert_manager_wildcard_certificate" {
#   name       = "wildcard-certificate"
#   repository = "https://bedag.github.io/helm-charts/"
#   chart      = "raw"
#   namespace  = kubernetes_namespace_v1.cert_manager.metadata[0].name
#   replace    = true
#
#   values = [
#     yamlencode({
#       resources = [
#         {
#           apiVersion = "cert-manager.io/v1"
#           kind       = "Certificate"
#           metadata = {
#             name      = "wildcard-${replace(var.primary_zone_name, ".", "-")}"
#             namespace = kubernetes_namespace_v1.cert_manager.metadata[0].name
#           }
#           spec = {
#             secretName = "wildcard-${replace(var.primary_zone_name, ".", "-")}-tls"
#             issuerRef = {
#               name = "letsencrypt-prod"
#               kind = "ClusterIssuer"
#             }
#             dnsNames = [
#               var.primary_zone_name,
#               "*.${var.primary_zone_name}"
#             ]
#           }
#         }
#       ]
#     })
#   ]
#
#   depends_on = [helm_release.cert_manager_cluster_issuer]
# }
