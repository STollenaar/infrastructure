output "vault_aws_client" {
  value = vault_aws_secret_backend.aws_client.path
}