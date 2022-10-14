module "statisticsbot_task" {
  source = "../templates/ecs_task"

  cluster_essentials = {
    ecs_cluster_id           = var.ecs_cluster.id
    private_dns_namespace_id = aws_service_discovery_private_dns_namespace.default_namespace.id
    security_groups          = var.security_groups
    subnets                  = var.subnets
    vpc_id                   = var.vpc_id
  }

  image    = "405934267152.dkr.ecr.ca-central-1.amazonaws.com/discordbots:statisticsbot"
  name     = "statisticsbot"
  iam_role = var.iam_role

  portMappings = [
    {
      containerPort = 3000
      hostPort      = 3000
      protocol      = "tcp"
    },
  ]

  resources = {
    cpu    = 512
    memory = 1024
  }

  environments = [
    {
      name  = "AWS_REGION"
      value = "ca-central-1"
    },
    {
      name  = "DATABASE_HOST"
      value = "${module.mongodb_task.discovery_service.name}.${aws_service_discovery_private_dns_namespace.default_namespace.name}"
    },
  ]

  secrets = [
    {
      name      = "AWS_PARAMETER_NAME"
      valueFrom = "arn:aws:ssm:ca-central-1:405934267152:parameter/discord_tokens/statisticsbot"
    },
  ]
}
