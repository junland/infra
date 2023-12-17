terraform {

  cloud {
    organization = "junland"
    workspaces {
      name = "networking"
    }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.5"
    }
  }
}

provider "cloudflare" {
  email     = var.cf_email
  api_token = var.cf_api_token
}
