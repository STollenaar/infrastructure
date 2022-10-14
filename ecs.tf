resource "aws_ecs_cluster" "spice_cluster" {
  name = "spice-cluster"

}

resource "aws_ecs_cluster_capacity_providers" "capacity" {
  cluster_name = aws_ecs_cluster.spice_cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

module "tasks" {
  source      = "./tasks"
  
  vpc_id      = aws_vpc.main_vpc.id
  ecs_cluster = aws_ecs_cluster.spice_cluster
  iam_role    = aws_iam_role.spices_role.arn

  security_groups = [
    aws_security_group.main_sc.id
  ]

  subnets = [
    aws_subnet.main_public_subnet.id
  ]
}
