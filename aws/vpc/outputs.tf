output "main_vpc" {
  value     = aws_vpc.main_vpc.id
  sensitive = true
}

output "main_subnets" {
  value = [
    aws_subnet.main_public_subnet_a.id,
    aws_subnet.main_public_subnet_b.id,
    aws_subnet.main_public_subnet_d.id,
  ]
  sensitive = true
}

output "main_security_groups" {
  value = [
    aws_security_group.main_sc.id
  ]
  sensitive = true
}
