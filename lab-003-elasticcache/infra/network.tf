# ========== VPC for Redis Lab
# resource "aws_vpc" "vpc-redis-lab" {
#   cidr_block = "10.1.0.0/16"
#   tags = {
#     Name  = "vpc-redis-lab"
#     label = local.label
#   }
# }
#
# #==========Private Subnet for Redis Lab
# resource "aws_subnet" "private_subnet" {
#   vpc_id            = aws_vpc.vpc-redis-lab.id
#   cidr_block        = "10.1.1.0/24"
#   availability_zone = var.availability_zone
#
#   tags = {
#     Name  = "private-subnet-redis-lab"
#     label = local.label
#   }
#
#   depends_on = [aws_vpc.vpc-redis-lab]
# }

#

# ========================= ELASTICACHE SECURITY=================================
# Security Groups for Redis Lab
# This file defines the security groups and rules for the Redis lab environment.
# resource "aws_security_group" "sg-redis" {
#   name        = "lab-sg-redis"
#   vpc_id      = aws_vpc.vpc-redis-lab.id
#   description = "Security group for Redis cluster"
#   tags = {
#      label = local.label
#   }
# }

# resource "aws_security_group_rule" "allow_to_redis" {
#   security_group_id = aws_security_group.sg-redis.id
#   type              = "ingress"
#   from_port         = 6379
#   to_port           = 6379
#   protocol          = "tcp"
#   cidr_blocks       = [aws_vpc.vpc-redis-lab.cidr_block]
#
# }
#
# resource "aws_security_group_rule" "allow_from_redis" {
#   security_group_id = aws_security_group.sg-redis.id
#   type              = "egress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   cidr_blocks       = [aws_vpc.vpc-redis-lab.cidr_block]
# }


# ========================= EC2 SECURITY=================================
# Security Group to EC2 Bastion and Vpc Endpoint
# resource "aws_security_group" "sg-redis-bastion" {
#   name        = "lab-redis-bastion-sg"
#   vpc_id      = aws_vpc.vpc-redis-lab.id
#   description = "Security group for Bastion Redis cluster"
#   tags = {
#     label = local.label
#   }
# }

# resource "aws_security_group_rule" "allow_to_bastion_redis" {
#   security_group_id = aws_security_group.sg-redis-bastion.id
#   type              = "ingress"
#   from_port         = 443
#   to_port           = 443
#   protocol          = "tcp"
#   cidr_blocks       = [aws_vpc.vpc-redis-lab.cidr_block]
# }


# resource "aws_security_group_rule" "allow_from_bastion_redis" {
#   description       = "Allow from bastion"
#   type              = "egress"
#   security_group_id = aws_security_group.sg-redis-bastion.id
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   cidr_blocks       = ["0.0.0.0/0"]
#   ipv6_cidr_blocks  = ["::/0"]
# }
#================== VPC ENDPOINT ==========
# resource "aws_vpc_endpoint" "endpoint_ec2message" {
#   service_name      = "com.amazonaws.${var.region}.ec2messages"
#   vpc_id            = aws_vpc.vpc-redis-lab.id
#   vpc_endpoint_type = "Interface"
#   subnet_ids        = [aws_subnet.private_subnet.id]
#   security_group_ids = [
#     aws_security_group.sg-redis-bastion.id
#   ]
#   tags = {
#     Name = "lab-ec2message-endpoint"
#   }
# }
#
# resource "aws_vpc_endpoint" "endpoint_ssm" {
#   service_name      = "com.amazonaws.${var.region}.ssm"
#   vpc_id            = aws_vpc.vpc-redis-lab.id
#   vpc_endpoint_type = "Interface"
#   subnet_ids        = [aws_subnet.private_subnet.id]
#   security_group_ids = [
#     aws_security_group.sg-redis-bastion.id
#   ]
#   tags = {
#     Name = "lab-ssm-endpoint"
#   }
# }
#
# resource "aws_vpc_endpoint" "endpoint_ssmmessages" {
#   service_name      = "com.amazonaws.${var.region}.ssmmessages"
#   vpc_id            = aws_vpc.vpc-redis-lab.id
#   vpc_endpoint_type = "Interface"
#   subnet_ids        = [aws_subnet.private_subnet.id]
#   security_group_ids = [
#     aws_security_group.sg-redis-bastion.id
#   ]
#   tags = {
#     Name = "lab-ssmmessages-endpoint"
#   }
# }


