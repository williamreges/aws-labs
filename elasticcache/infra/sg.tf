
# Security Groups for Redis Lab
# This file defines the security groups and rules for the Redis lab environment.
resource "aws_security_group" "sg-redis" {
  name        = "lab-redis-sg"
  vpc_id      = aws_vpc.vpc-redis-lab.id
  description = "Security group for Redis cluster"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    label = "laboratorio-elasticache"
  }
}

resource "aws_security_group_rule" "allow_to_redis" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.sg-redis.id
}

resource "aws_security_group" "sg-redis-bastion" {
  name        = "lab-redis-bastion-sg"
  vpc_id      = aws_vpc.vpc-redis-lab.id
  description = "Security group for Bastion Redis cluster"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    label = "laboratorio-elasticache"
  }
}

resource "aws_security_group_rule" "allow_to_bastion_redis" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg-redis-bastion.id
}




# Bastion Host Security Group
# This security group allows the bastion host to connect to the Redis instance.
# resource "aws_security_group" "sg-bastion-redis" {
#   name   = "lab-bastion-redis-sg"
#   vpc_id = aws_vpc.vpc-redis-lab.id
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
#
# resource "aws_security_group_rule" "allow_bastion_to_redis" {
#   type              = "ingress"
#   from_port         = 6379
#   to_port           = 6379
#   protocol          = "tcp"
#   security_group_id = aws_security_group.sg-bastion-redis.id
#
# }
