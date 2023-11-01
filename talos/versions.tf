terraform {
  backend "s3" {
    bucket  = "stollenaar-terraform-states"
    key     = "infrastructure/proxmox_terraform.tfstate"
    region  = "ca-central-1"
    profile = "personal"
  }
  required_providers {
    # archive = {
    #   source  = "hashicorp/archive"
    #   version = "~> 2.2.0"
    # }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20.1"
    }
    awsprofiler = {
      version = "~> 0.0.1"
      source  = "spices.dev/stollenaar/awsprofiler"
    }
    hcp = {
      version = "~> 0.75.0"
      source  = "hashicorp/hcp"
    }
    http = {
      version = "~> 2.2.0"
      source  = "hashicorp/http"
    }
    helm = {
      version = "~> 2.10.1"
      source  = "hashicorp/helm"
    }
    kubernetes = {
      version = "~> 2.23.0"
      source  = "hashicorp/kubernetes"
    }
    # external = {
    #   source  = "hashicorp/external"
    #   version = "~> 2.2.0"
    # }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.1"
    }
    # random = {
    #   source  = "hashicorp/random"
    #   version = "~> 3.1.0"
    # }
    # template = {
    #   source  = "hashicorp/template"
    #   version = "~> 2.2.0"
    # }
    # tailscale = {
    #   source  = "tailscale/tailscale"
    #   version = "0.13.7"
    # }
    # vault = {
    #   source  = "hashicorp/vault"
    #   version = "~> 3.21.0"
    # }
  }
  required_version = ">= 1.2.2"
}
