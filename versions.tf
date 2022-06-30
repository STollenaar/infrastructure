terraform {
  backend "s3" {
    bucket  = "stollenaar-terraform-states"
    key     = "infrastructure/terraform.tfstate"
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
    http = {
      version = "~> 2.2.0"
      source  = "hashicorp/http"
    }
    # external = {
    #   source  = "hashicorp/external"
    #   version = "~> 2.2.0"
    # }
    # local = {
    #   source  = "hashicorp/local"
    #   version = "~> 2.1.0"
    # }
    # null = {
    #   source  = "hashicorp/null"
    #   version = "~> 3.1.0"
    # }
    # random = {
    #   source  = "hashicorp/random"
    #   version = "~> 3.1.0"
    # }
    # template = {
    #   source  = "hashicorp/template"
    #   version = "~> 2.2.0"
    # }
  }
  required_version = ">= 1.2.2"
}
