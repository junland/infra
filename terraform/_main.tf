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
      source = "hashicorp/kubernetes"
    }

    helm = {
      source = "hashicorp/helm"
    }
  }
}

provider "cloudflare" {
  email     = var.cf_email
  api_token = var.cf_api_token
}

provider "http" {

}

provider "kubernetes" {
  config_path = var.kube_config_path
}

provider "helm" {
  kubernetes = {
    config_path = var.kube_config_path
  }
}
