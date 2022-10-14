resource "aws_ecs_task_definition" "task" {
  family                   = var.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.resources.cpu
  memory                   = var.resources.memory
  execution_role_arn       = var.iam_role
  task_role_arn            = var.iam_role
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  dynamic "volume" {
    for_each = { for v in var.volumes : v.name => v }
    content {
      name = volume.key
    }
  }

  container_definitions = jsonencode([

    {
      cpu          = var.resources.cpu
      memory       = var.resources.memory
      environment  = var.environments
      secrets      = var.secrets
      essential    = true
      image        = var.image
      name         = var.name
      portMappings = var.portMappings
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-group         = "/ecs/${var.name}"
          awslogs-region        = "ca-central-1"
          awslogs-stream-prefix = "ecs"
        }
        secretOptions = []
      }
      mountPoints = [for v in var.volumes : { containerPath = v.path, sourceVolume = v.name }]
      volumesFrom = []
    },
  ])
}
