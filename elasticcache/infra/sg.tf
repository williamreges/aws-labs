
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
  security_group_id = aws_security_group.sg-redis.id
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
#   self              = true
  cidr_blocks       = [aws_vpc.vpc-redis-lab.cidr_block]

}

resource "aws_security_group" "sg-redis-bastion" {
  name        = "lab-redis-bastion-sg"
  vpc_id      = aws_vpc.vpc-redis-lab.id
  description = "Security group for Bastion Redis cluster"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  tags = {
    label = "laboratorio-elasticache"
  }
}

resource "aws_security_group_rule" "allow_to_bastion_redis" {
  security_group_id = aws_security_group.sg-redis-bastion.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       =  ["0.0.0.0/0"]

}
