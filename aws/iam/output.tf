output "iam_users" {
  value = {
    vault_user   = aws_iam_user.vault_user
    route53_user = aws_iam_user.route53_user
  }
}

output "iam_roles" {
  value = {
    vault_ecr_role    = aws_iam_role.vault_ecr
    external_dns_role = aws_iam_role.extenral_dns_role
  }
}
