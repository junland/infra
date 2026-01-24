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

variable "primary_zone_name" {
  type        = string
  description = "Name of the primary zone."
}

variable "kube_config_path" {
    type = string
    description = "Location for kubectl config."
    default = "~/.kube/config"
}

variable "primary_hosts" {
  type = list(object({
    name     = string
    ip       = string
    svcs     = list(string)
    wildcard = optional(bool, false)
  }))
  description = "Hosts within the primary zone."
}
