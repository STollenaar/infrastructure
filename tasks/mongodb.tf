resource "aws_ecs_task_definition" "mongo" {
  family                   = "mongodb"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = "arn:aws:iam::405934267152:role/ecsTaskExecutionRole"
  runtime_platform {
    operating_system_family = "LINUX"
  }
  volume {
    name = "mongodb-volume"
  }
  container_definitions = jsonencode([

    {
      cpu         = 0
      environment = []
      essential   = true
      image       = "mongo:4.4.4"
      mountPoints = [
        {
          containerPath = "/var/lib/mongodb"
          sourceVolume  = "mongodb-volume"
        },
      ]
      name = "mongodb"
      portMappings = [
        {
          containerPort = 27017
          hostPort      = 27017
          protocol      = "tcp"
        },
      ]
      volumesFrom = []
    },
  ])
}

resource "aws_ecs_service" "mongo" {
  name = "mongodb"

  cluster         = var.ecs_cluster.id
  task_definition = aws_ecs_task_definition.mongo.arn
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
    registry_arn = aws_service_discovery_service.mongodb_discovery_service.arn
  }
}

resource "aws_service_discovery_service" "mongodb_discovery_service" {
  name = "mongodb"

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
