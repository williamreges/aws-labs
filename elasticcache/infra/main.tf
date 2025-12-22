resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "lab-subnet-group-redis"
  subnet_ids = [aws_subnet.private_subnet.id]
}

# Redis Cluster
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
    Name  = "lab-redis-cluster"
    label = "laboratorio-elasticache"
  }
}



# # IAM Role para SSM
#
#
# Atualizar a instância EC2
# resource "aws_instance" "bastion_redis_client" {
#   ami                  = "ami-0484b27e9143d1299"
#   instance_type        = "t2.micro"
#   subnet_id            = aws_subnet.private_subnet.id
#   iam_instance_profile = aws_iam_instance_profile.bastion_profile.name
#
#   vpc_security_group_ids = [
#     aws_security_group.sg-redis.id,
#     aws_security_group.sg-redis-bastion.id
#   ]
#   associate_public_ip_address = false
#
#   user_data = <<-EOF
#           #!/bin/bash
#           curl -O https://bootstrap.pypa.io/get-pip.py python3 get-pip.py --user
#           sleep 30
#           pip install redis
#           EOF
#
#   depends_on = [aws_elasticache_cluster.redis]
#
#   tags = {
#     Name = "lab-bastion-redis-client"
#   }
# }





