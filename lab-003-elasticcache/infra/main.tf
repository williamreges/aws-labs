

# === Bastion EC2 para criar tunuel de conexão entre o pc local ao Elasticache
# resource "aws_instance" "bastion_redis_client" {
#   ami                  = "ami-0484b27e9143d1299"
#   instance_type        = "t2.micro"
#   subnet_id            = data.aws_subnet.public_selectec.id
#   iam_instance_profile = aws_iam_instance_profile.bastion_profile.name
#
#   vpc_security_group_ids = [
#     aws_security_group.sg-redis-bastion.id
#   ]
#   associate_public_ip_address = false
#
#   user_data = <<-EOF
#           #!/bin/bash
#           curl -O https://bootstrap.pypa.io/get-pip.py
#           sudo chmod 777 get-pip.py
#           python3 get-pip.py --user
#           pip install redis
#           EOF
#
#   #   depends_on = [aws_elasticache_cluster.redis]
#
#   tags = {
#     Name = "lab-bastion-redis"
#   }
# }





