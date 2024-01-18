locals {
  # Automatically load provider variables
  provider_vars = read_terragrunt_config("${get_original_terragrunt_dir()}/provider.hcl")

  # Extract the variables we need for easy access
  providers = local.provider_vars.locals.providers
}

remote_state {
  backend = "s3"
  generate = {
    path      = "grunt_backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "stollenaar-terraform-states"

    key     = "infrastructure/aws/${path_relative_to_include()}/terraform.tfstate"
    region  = "ca-central-1"
    encrypt = true
  }
}

generate "provider" {
  path      = "grunt_providers.tf"
  if_exists = "overwrite"
  contents  = <<EOF
        provider "aws" {
            region = "ca-central-1"
        }
    EOF
}

generate "versions" {
  path      = "grunt_versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
        required_providers {
            aws = {
            source  = "hashicorp/aws"
            version = "~> 4.20.1"
            }
            null = {
            source  = "hashicorp/null"
            version = "~> 3.2.1"
            }
        }
        required_version = ">= 1.2.2"
    }
    EOF
}