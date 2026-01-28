locals {
  wildcard_host                = "*.${var.k3s_cert_manager_domain}"
  wildcard_secret_name         = "wildcard-cert"
  wildcard_cluster_issuer_name = "letsencrypt-dns"
}
