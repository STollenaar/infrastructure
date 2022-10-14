resource "aws_ecs_service" "service" {
  name = var.name

  cluster         = var.cluster_essentials.ecs_cluster_id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.cluster_essentials.subnets
    security_groups  = var.cluster_essentials.security_groups
    assign_public_ip = true
  }
  service_registries {
    registry_arn = aws_service_discovery_service.discovery_service.arn
  }
}
