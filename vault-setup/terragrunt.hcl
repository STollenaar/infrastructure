include "root" {
  path = find_in_parent_folders("root.hcl")
}

# terraform {
#   before_hook "before_hook" {
#     commands = ["apply", "destroy", "plan"]
#     execute  = ["./conf/start_service.sh", read_terragrunt_config("${find_in_parent_folders("root.hcl")}").locals.kubeconfig_file]
#     # get_env("KUBES_ENDPOINT", "somedefaulturl") you can get env vars or pass in params as needed to the script
#   }

#   after_hook "after_hook" {
#     commands     = ["apply", "destroy", "plan"]
#     execute      = ["./conf/stop_service.sh"]
#     run_on_error = true
#   }
# }

dependencies {
  paths = ["../kubernetes"]
}

