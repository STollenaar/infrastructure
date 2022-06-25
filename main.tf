resource "aws_instance" "bot_instance" {
  ami                                  = "ami-0e4208b856d700843"
  associate_public_ip_address          = true
  disable_api_termination              = false
  ebs_optimized                        = false
  get_password_data                    = false
  hibernation                          = false
  iam_instance_profile                 = aws_iam_role.spices_role.id
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t4g.medium"
  key_name                             = "stollenaar"
  monitoring                           = false
  source_dest_check                    = true
  subnet_id                            = aws_subnet.main_public_subnet.id
  tags = {
    "Name" = "Spices"
  }

  vpc_security_group_ids = [
    aws_security_group.main_sc.id
  ]

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "optional"
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    tags = {
      "Name" = "Spices"
    }
    volume_size = 40
    volume_type = "gp2"
  }

  user_data = templatefile("${path.module}/conf/discordBotInits.bash.tpl", {
    dockerCompose = filebase64("${path.module}/conf/discordbots-compose.yml")
  })
}

resource "aws_eip" "spices_ip" {
  instance = aws_instance.bot_instance.id
  vpc      = true
}
