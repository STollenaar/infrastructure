
resource "aws_ecs_cluster" "discord_bots_cluster" {
  name = "discord-bots"
}


resource "aws_ecs_cluster_capacity_providers" "discord_bots_capacity_providers" {
  cluster_name = aws_ecs_cluster.discord_bots_cluster.name

  capacity_providers = ["FARGATE_SPOT", aws_ecs_capacity_provider.nano_provider.name]

  #   default_capacity_provider_strategy {
  #     base              = 1
  #     weight            = 100
  #     capacity_provider = "FARGATE_SPOT"
  #   }
}

resource "aws_ecr_repository" "discord_bots" {
  name = "discordbots"
}

resource "aws_launch_template" "nano_template" {
  name_prefix = "nano-template"
  image_id    = data.aws_ami.ecs_ami.id

  user_data = base64encode(templatefile("${path.module}/conf/userdata.bash",
    {
      cluster_name = aws_ecs_cluster.discord_bots_cluster.name
    }
  ))
  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type = "one-time"
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.main_sc.id]
  }
  iam_instance_profile {
    name = aws_iam_role.spices_role.name
  }
  instance_type = "t4g.nano"
}

resource "aws_autoscaling_group" "nano_scaler" {
  # ... other configuration, including potentially other tags ...
  vpc_zone_identifier = [
    aws_subnet.main_public_subnet_a.id,
    aws_subnet.main_public_subnet_b.id,
    aws_subnet.main_public_subnet_d.id,
  ]
  protect_from_scale_in = true

  launch_template {
    id      = aws_launch_template.nano_template.id
    version = aws_launch_template.nano_template.latest_version
  }
  min_size = 0
  max_size = 5
  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "nano_provider" {
  name = "nano-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.nano_scaler.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 100
    }
  }
}
