
resource "aws_ecs_cluster" "app_cluster" {
  name = "app-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "app_cluster_capacity" {
  cluster_name = aws_ecs_cluster.app_cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }
  depends_on = [aws_ecs_cluster.app_cluster]
}