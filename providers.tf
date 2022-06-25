provider "aws" {
  profile = local.used_profile.name
  region  = coalesce(local.used_profile.region, "ca-central-1")
}
