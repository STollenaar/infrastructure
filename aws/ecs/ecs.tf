
resource "aws_ecs_cluster" "discord_bots_cluster" {
  name = "discord-bots"
}


resource "aws_ecs_cluster_capacity_providers" "discord_bots_capacity_providers" {
  cluster_name = aws_ecs_cluster.discord_bots_cluster.name

  capacity_providers = ["FARGATE_SPOT", aws_ecs_capacity_provider.nano_provider.name]
}

resource "aws_launch_template" "nano_template" {
  name_prefix = "nano-template"
  image_id    = data.aws_ami.ecs_ami.id

  user_data = data.template_cloudinit_config.config.rendered

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type = "gp3"
    }
  }
  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type = "one-time"
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [data.terraform_remote_state.vpc.outputs.main_security_groups[0]]
  }
  iam_instance_profile {
    name = data.terraform_remote_state.iam.outputs.spices_role.id
  }
  instance_type = "t4g.nano"
}

resource "aws_autoscaling_group" "nano_scaler" {
  vpc_zone_identifier = data.terraform_remote_state.vpc.outputs.main_subnets
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

resource "aws_service_discovery_http_namespace" "discord_bots_namespace" {
  name        = "discord-bots"
  description = "discord bots namespace"
}
