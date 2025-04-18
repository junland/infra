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

variable "primary_zone_name" {
  type        = string
  description = "Name of the primary zone."
}

variable "primary_hosts" {
  type = object({
    name = string
    ip   = string
    svcs = list(string)
  })
  description = "Hosts within the primary zone."
}
