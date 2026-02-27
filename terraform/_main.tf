terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3"
    }
  }
}

provider "cloudflare" {
  email     = var.cf_email
  api_token = var.cf_api_token
}

provider "http" {

}


