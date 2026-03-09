variable "k8s_kubectl_config_path" {
  type        = string
  description = "Location for k8s kubectl config."
  default     = "~/.kube/config"
}

variable "k8s_loadbalancer_ip" {
  type        = string
  description = "Static IP for the k8s LoadBalancer Service."
}

variable "k8s_loadbalancer_pool" {
  type        = string
  description = "IP address pool for the k8s LoadBalancer Service."
}

variable "k8s_cert_manager_email" {
  type        = string
  description = "Email address for Let's Encrypt certificate notifications."
}

variable "k8s_cert_manager_domain" {
  type        = string
  description = "Domain name for Let's Encrypt certificates."
}

variable "k8s_longhorn_install" {
  type        = bool
  description = "Install longhorn resources."
  default     = false
}

variable "k8s_longhorn_admin_username" {
  type        = string
  description = "Username for longhorn admin dashboard."
  default     = "admin"
}

variable "k8s_longhorn_admin_password" {
  type        = string
  description = "Encrypted password for longhorn admin dashboard."
}

variable "k8s_cert_manager_cf_api_token" {
  type        = string
  description = "Cloudflare API token for cert-manager DNS01 challenges."
  sensitive   = true
}
