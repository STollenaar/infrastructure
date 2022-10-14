resource "aws_ecs_task_definition" "statisticsbot" {
  family                   = "statisticsbot"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = var.iam_role
  task_role_arn            = var.iam_role
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([

    {
      cpu = 0
      environment = [
        {
          name  = "AWS_REGION"
          value = "ca-central-1"
        },
        {
          name  = "DATABASE_HOST"
          value = "${aws_service_discovery_service.mongodb_discovery_service.name}.${aws_service_discovery_private_dns_namespace.default_namespace.name}"
        },
      ]
      secrets = [
        {
          name      = "AWS_PARAMETER_NAME"
          valueFrom = "arn:aws:ssm:ca-central-1:405934267152:parameter/discord_tokens/statisticsbot"
        },
      ]
      essential = true
      image     = "405934267152.dkr.ecr.ca-central-1.amazonaws.com/discordbots:statisticsbot"
      name      = "statisticsbot"
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-group         = "/ecs/statisticsbot"
          awslogs-region        = "ca-central-1"
          awslogs-stream-prefix = "ecs"
        }
        secretOptions = []
      }
      volumesFrom = []
    },
  ])
}

resource "aws_ecs_service" "statisticsbot" {
  name = "statisticsbot"

  cluster         = var.ecs_cluster.id
  task_definition = aws_ecs_task_definition.statisticsbot.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.subnets
    security_groups  = var.security_groups
    assign_public_ip = true
  }
  service_registries {
    registry_arn = aws_service_discovery_service.statisticsbot_discovery_service.arn
  }
}

resource "aws_service_discovery_service" "statisticsbot_discovery_service" {
  name = "statisticsbot"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.default_namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
