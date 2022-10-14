module "mongodb_task" {
  source = "../templates/ecs_task"

  cluster_essentials = {
    ecs_cluster_id           = var.ecs_cluster.id
    private_dns_namespace_id = aws_service_discovery_private_dns_namespace.default_namespace.id
    security_groups          = var.security_groups
    subnets                  = var.subnets
    vpc_id                   = var.vpc_id
  }

  name     = "mongodb"
  image    = "mongo:4.4.4"
  iam_role = var.iam_role

  resources = {
    cpu    = 512
    memory = 1024
  }

  portMappings = [
    {
      containerPort = 27017
      hostPort      = 27017
      protocol      = "tcp"
    },
  ]

  volumes = [
    {
      path = "/var/lib/mongodb"
      name = "mongodb-volume"
    },
  ]
}
