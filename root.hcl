locals {
  kubeconfig_file = "/home/stollenaar/.kube/config"

  # Automatically load provider variables
  provider_vars = read_terragrunt_config("${get_original_terragrunt_dir()}/provider.hcl")

  # Extract the variables we need for easy access
  providers = local.provider_vars.locals.providers


  raw_versions = jsondecode(file("versions.tf.json"))
  # Remove undesired keys
  filtered_versions = {
    terraform = {
      required_providers = { for k, v in local.raw_versions.terraform.required_providers : k => v if contains(local.providers, k) }
    }
  }

  raw_providers = jsondecode(templatefile("providers.hcl.json", {
    kubeconfig_file = local.kubeconfig_file
  }))
  # Remove undesired keys
  filtered_providers = {
    provider = { for k, v in local.raw_providers.provider : k => v if contains(local.providers, k) }
  }

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
  path              = "grunt_providers.tf.json"
  if_exists         = "overwrite"
  disable_signature = true
  contents          = jsonencode(local.filtered_providers)
}

generate "versions" {
  path              = "grunt_versions.tf.json"
  if_exists         = "overwrite"
  disable_signature = true
  contents          = jsonencode(local.filtered_versions)
}