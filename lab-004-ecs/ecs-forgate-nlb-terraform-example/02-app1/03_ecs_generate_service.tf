


resource "aws_ecs_service" "service_app1" {
  name            = "service-app1"
  cluster         = data.aws_ecs_cluster.app_cluster.id
  task_definition = data.aws_ecs_task_definition.app1_latest.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [data.aws_subnet.a.id, data.aws_subnet.c.id]
    security_groups  = [data.aws_security_group.default.id]
    assign_public_ip = true
  }

  enable_execute_command = true

  tags = {
    key1 = "value1"
    key2 = "value2"
    key3 = "value3"
  }
}