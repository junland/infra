variable "cf_email" {
  type        = string
  description = "Email registered with Cloudflare."
}

variable "cf_api_token" {
  type        = string
  description = "API token generated from Cloudflare."
}

variable "cf_account_id" {
  type        = string
  description = "Cloudflare account ID."
}

variable "do_api_token" {
  type        = string
  description = "API token generated from Digital Ocean."
}

variable "cf_primary_zone_name" {
  type        = string
  description = "Name of the primary zone."
}

variable "cf_primary_hosts" {
  type = list(object({
    name     = string
    ip       = string
    svcs     = list(string)
    wildcard = optional(bool, false)
  }))
  description = "Hosts within the primary zone."
}

variable "kube_config_path" {
  type        = string
  description = "Location for kubectl config."
  default     = "~/.kube/config"
}

variable "k3s_loadbalancer_ip" {
  type        = string
  description = "Static IP for the K3s LoadBalancer Service."
}

variable "k3s_loadbalancer_pool" {
  type        = string
  description = "IP address pool for the K3s LoadBalancer Service."
}

variable "k3s_cert_manager_email" {
  type        = string
  description = "Email address for Let's Encrypt certificate notifications."
}

variable "k3s_cert_manager_domain" {
  type        = string
  description = "Domain name for Let's Encrypt certificates."
}

variable "k3s_longhorn_install" {
  type        = bool
  description = "Install longhorn resources."
  default     = false
}

variable "k3s_longhorn_admin_username" {
  type        = string
  description = "Username for longhorn admin dashboard."
  default     = "admin"
}

variable "k3s_longhorn_admin_password" {
  type        = string
  description = "Encrypted password for longhorn admin dashboard."
}
