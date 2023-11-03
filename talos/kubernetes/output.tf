output "vault_namespace" {
  value = kubernetes_namespace.vault
}

output "vault_user" {
  value = aws_iam_user.vault_user
}

output "vault_ecr_role" {
  value = aws_iam_role.vault_ecr
}