output "task_definition" {
  value = aws_ecs_task_definition.task
}

output "service" {
  value = aws_ecs_service.service
}

output "discovery_service" {
  value = aws_service_discovery_service.discovery_service
}
