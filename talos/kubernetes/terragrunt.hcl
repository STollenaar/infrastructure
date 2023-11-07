include "root" {
  path = find_in_parent_folders()
}

dependency "openebs" {
  config_path  = "../openebs"
  skip_outputs = true
}