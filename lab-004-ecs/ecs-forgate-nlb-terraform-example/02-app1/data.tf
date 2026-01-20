data "aws_caller_identity" "aws_current" {
  
}

data "aws_vpc" "default" {
  filter {
    name   = "instance-tenancy"
    values = ["default"]
  }
}

data "aws_security_group" "default" {
  filter {
    name   = "group-name"
    values = ["default"]
  }
}

data "aws_security_group" "web" {
  filter {
    name   = "group-name"
    values = ["aulaaws-security-web"]
  }
}

data "aws_subnet" "a" {
  filter {
    name   = "availability-zone"
    values = ["sa-east-1a"]
  }
}

data "aws_subnet" "c" {
  filter {
    name   = "availability-zone"
    values = ["sa-east-1c"]
  }
}

data "aws_ecs_cluster" "app_cluster" {
  filter {
    name   = "cluster-name"
    values = ["app-cluster"]
  }
 
}

data "aws_ecs_task_definition" "app1_latest" {
  family = "app1-task"
  # Pega a última revision automaticamente
  status = "ACTIVE"
}

