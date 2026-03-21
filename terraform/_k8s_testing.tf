# Use k8s module to deploy local kubernetes cluster for testing purposes.
# This is not intended for production use and should only be used in a local testing environment.
module "k8s" {
  count = var.k8s_enable_module ? 1 : 0

  source = "./modules/k8s"

  k8s_kubectl_config_path       = var.k8s_kubectl_config_path
  k8s_loadbalancer_ip           = var.k8s_loadbalancer_ip
  k8s_loadbalancer_pool         = local.k8s_pool_range
  k8s_cert_manager_email        = var.k8s_cert_manager_email
  k8s_cert_manager_domain       = var.k8s_cert_manager_domain
  k8s_longhorn_admin_password   = var.k8s_longhorn_admin_password
  k8s_cert_manager_cf_api_token = var.cf_api_token
}
