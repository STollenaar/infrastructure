resource "aws_vpc" "main_vpc" {
  assign_generated_ipv6_cidr_block = false
  cidr_block                       = "10.0.0.0/16"
  enable_classiclink               = false
  enable_classiclink_dns_support   = false
  enable_dns_hostnames             = true
  enable_dns_support               = true
  instance_tenancy                 = "default"
  tags = {
    "Name" = "main-vpc"
  }
}

resource "aws_subnet" "main_public_subnet" {
  availability_zone                              = "ca-central-1a"
  assign_ipv6_address_on_creation                = false
  cidr_block                                     = "10.0.0.0/20"
  enable_dns64                                   = false
  enable_resource_name_dns_a_record_on_launch    = false
  enable_resource_name_dns_aaaa_record_on_launch = false
  ipv6_native                                    = false
  map_public_ip_on_launch                        = false
  private_dns_hostname_type_on_launch            = "ip-name"
  tags = {
    "Name" = "main-subnet-public-ca-central-1a"
  }

  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_security_group" "main_sc" {
  description = "Main security group"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "Internet Access"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  revoke_rules_on_delete = true
  name                   = "mainSC"
  vpc_id                 = aws_vpc.main_vpc.id

}

resource "aws_security_group_rule" "current_ip_ssh_rule" {
  type              = "ingress"
  security_group_id = aws_security_group.main_sc.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  description       = "Current IP"
  cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
}
