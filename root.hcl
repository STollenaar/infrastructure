locals {
  kubeconfig_file = "/home/stollenaar/.kube/config"

  # Automatically load provider variables
  provider_vars = read_terragrunt_config("${get_original_terragrunt_dir()}/provider.hcl")

  # Extract the variables we need for easy access
  providers = local.provider_vars.locals.providers
}

terraform_binary = "/usr/local/bin/tofu"

remote_state {
  backend = "s3"
  generate = {
    path      = "grunt_backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "stollenaar-terraform-states"

    key     = "infrastructure/${path_relative_to_include()}/terraform.tfstate"
    region  = "ca-central-1"
    encrypt = true
  }
}

generate "provider" {
  path      = "grunt_providers.tf"
  if_exists = "overwrite"
  contents  = <<EOF
        %{if contains(local.providers, "aws")}
        provider "aws" {
            region = "ca-central-1"
        }
        %{endif}
        %{if contains(local.providers, "kubernetes")}
        provider "kubernetes" {
            config_path = "${local.kubeconfig_file}"
        }
        %{endif}
        %{if contains(local.providers, "hcp")}
        provider "hcp" {
            client_id     = data.aws_ssm_parameter.vault_client_id.value
            client_secret = data.aws_ssm_parameter.vault_client_secret.value
        }
        %{endif}
        %{if contains(local.providers, "helm")}
        provider "helm" {
            kubernetes {
                config_path = "${local.kubeconfig_file}"
            }
        }
        %{endif}
        %{if contains(local.providers, "vault")}
        provider "vault" {
            token   = data.hcp_vault_secrets_secret.vault_root.secret_value
            address = "http://localhost:8200"
        }
        %{endif}
        %{if contains(local.providers, "talos")}
        provider "talos" {}
        %{endif}
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
            hcp = {
            version = "~> 0.75.0"
            source  = "hashicorp/hcp"
            }
            helm = {
            version = "~> 2.10.1"
            source  = "hashicorp/helm"
            }
            kubernetes = {
            version = "~> 2.23.0"
            source  = "hashicorp/kubernetes"
            }
            null = {
            source  = "hashicorp/null"
            version = "~> 3.2.1"
            }
            %{if contains(local.providers, "vault")}
            vault = {
                source  = "hashicorp/vault"
                version = "~> 3.21.0"
            }
            %{endif}
            %{if contains(local.providers, "talos")}
            talos = {
                source  = "siderolabs/talos"
                version = "0.3.4"
            }            
            %{endif}
        }
        required_version = ">= 1.2.2"
    }
    EOF
}