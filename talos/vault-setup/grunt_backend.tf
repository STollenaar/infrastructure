# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket  = "stollenaar-terraform-states"
    encrypt = true
    key     = "infrastructure/vault-setup/terraform.tfstate"
    region  = "ca-central-1"
  }
}
