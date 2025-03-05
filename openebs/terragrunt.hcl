include "root" {
  path = find_in_parent_folders()
}

terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
    arguments = [
      "-var=kubeconfig_file=${read_terragrunt_config("${find_in_parent_folders()}").locals.kubeconfig_file}"
    ]
  }
}
