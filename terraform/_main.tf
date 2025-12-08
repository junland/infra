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

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2"
    }
  }
}

provider "cloudflare" {
  email     = var.cf_email
  api_token = var.cf_api_token
}

provider "http" {

}

provider "digitalocean" {
  token = var.do_api_token
}
