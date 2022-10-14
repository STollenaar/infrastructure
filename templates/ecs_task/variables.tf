variable "cluster_essentials" {
  type = object({
    ecs_cluster_id           = string
    subnets                  = list(string)
    security_groups          = list(string)
    vpc_id                   = string
    private_dns_namespace_id = string
  })
}

variable "iam_role" {}

variable "name" {
  type = string
}

variable "image" {
  type = string
}

variable "resources" {
  type = object(
    { cpu    = number,
      memory = number
    }
  )
}

variable "environments" {
  type = list(object({
    name  = string,
    value = string
  }))
  default = []
}

variable "secrets" {
  type = list(object({
    name      = string,
    valueFrom = string
  }))
  default = []
}

variable "portMappings" {
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))
  default = []
}

variable "volumes" {
  type = list(object({
    name = string,
    path = string
  }))
  default = []
}
