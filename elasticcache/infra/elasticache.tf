resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "lab-subnet-group-redis"
  subnet_ids = [aws_subnet.private_subnet.id]
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "lab-redis-cluster"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379
  availability_zone    = var.availability_zone
  security_group_ids   = [aws_security_group.sg-redis.id]
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name

  depends_on = [aws_vpc.vpc-redis-lab, aws_subnet.private_subnet, aws_security_group.sg-redis]

  tags = {
    Name = "lab-redis-cluster"
  }
}





