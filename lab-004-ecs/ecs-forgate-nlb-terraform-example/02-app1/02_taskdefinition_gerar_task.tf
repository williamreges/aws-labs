provider "aws" {
  profile = "aulaaws"
  region  = "sa-east-1"
}

resource "aws_ecs_task_definition" "app1" {
  family                   = "app1-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::${data.aws_caller_identity.aws_current.account_id}:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::${data.aws_caller_identity.aws_current.account_id}:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
      name      = "container-app1"
      image     = "${data.aws_caller_identity.aws_caller_identity.account_id}.dkr.ecr.sa-east-1.amazonaws.com/app1"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
          name          = "container-app1-80-tcp"
          appProtocol   = "http"
        }
      ]
      environment      = []
      environmentFiles = []
      mountPoints      = []
      volumesFrom      = []
      ulimits          = []
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/app1-task"
          mode                  = "non-blocking"
          awslogs-create-group  = "true"
          max-buffer-size       = "25m"
          awslogs-region        = "sa-east-1"
          awslogs-stream-prefix = "ecs"
        }
        secretOptions = []
      }
      systemControls = []
    }
  ])
}
