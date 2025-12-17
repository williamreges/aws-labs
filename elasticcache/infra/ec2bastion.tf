# # IAM Role para SSM
#
#
# # Atualizar a instância EC2
# resource "aws_instance" "bastion_redis_client" {
#   ami           = "ami-0484b27e9143d1299"
#   instance_type = "t2.micro"
#   subnet_id     = aws_subnet.private_subnet.id
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