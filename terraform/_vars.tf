variable "cf_email" {
  type        = string
  description = "Email registered with Cloudflare."
}

variable "cf_api_token" {
  type        = string
  description = "API token generated from Cloudflare."
  sensitive   = true
}

variable "cf_account_id" {
  type        = string
  description = "Cloudflare account ID."
}

variable "do_api_token" {
  type        = string
  description = "API token generated from Digital Ocean."
  sensitive   = true
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

variable "k8s_enable_module" {
  type        = bool
  description = "Enable k8s module."
  default     = false
}

variable "k8s_kubectl_config_path" {
  type        = string
  description = "Location for k8s kubectl config."
  default     = "~/.kube/config"
}

variable "k8s_loadbalancer_ip" {
  type        = string
  description = "Static IP for the k8s LoadBalancer Service."

  # Validate that the IP address is in a valid format based on if the k8s module is enabled.
  validation {
    condition     = var.k8s_enable_module == false || (var.k8s_enable_module == true && can(regex("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.k8s_loadbalancer_ip)))
    error_message = "k8s_loadbalancer_ip must be a valid IP address if k8s_enable_module is true."
  }
}

variable "k8s_loadbalancer_pool_start" {
  type        = string
  description = "Start IP address for the k8s LoadBalancer Service IP pool."

  # Validate that the start IP is less than the end IP based on if the k8s module is enabled.
  validation {
    condition     = var.k8s_enable_module == false || (var.k8s_enable_module == true && var.k8s_loadbalancer_pool_start < var.k8s_loadbalancer_pool_end)
    error_message = "k8s_loadbalancer_pool_start must be less than k8s_loadbalancer_pool_end if k8s_enable_module is true."
  }
}

variable "k8s_loadbalancer_pool_end" {
  type        = string
  description = "End IP address for the k8s LoadBalancer Service IP pool."

  # Validate that the end IP is greater than the start IP based on if the k8s module is enabled.
  validation {
    condition     = var.k8s_enable_module == false || (var.k8s_enable_module == true && var.k8s_loadbalancer_pool_end > var.k8s_loadbalancer_pool_start)
    error_message = "k8s_loadbalancer_pool_end must be greater than k8s_loadbalancer_pool_start if k8s_enable_module is true."
  }
}

variable "k8s_cert_manager_email" {
  type        = string
  description = "Email address for Let's Encrypt certificate notifications."

  # Validate that the email is enter based on if the k8s module is enabled.
  validation {
    condition     = var.k8s_enable_module == false || (var.k8s_enable_module == true && length(var.k8s_cert_manager_email) > 0)
    error_message = "k8s_cert_manager_email must be provided if k8s_enable_module is true."
  }
}

variable "k8s_cert_manager_domain" {
  type        = string
  description = "Domain name for Let's Encrypt certificates."


  # Validate that the domain name is enter based on if the k8s module is enabled.
  validation {
    condition     = var.k8s_enable_module == false || (var.k8s_enable_module == true && length(var.k8s_cert_manager_domain) > 0)
    error_message = "k8s_cert_manager_domain must be provided if k8s_enable_module is true."
  }
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
