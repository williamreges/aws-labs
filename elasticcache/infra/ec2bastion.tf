resource "aws_instance" "bastion_redis_client" {
  ami           = "ami-0484b27e9143d1299" #ami free tier
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg-redis.id]

  user_data = <<-EOF
          #!/bin/bash
          curl -O https://bootstrap.pypa.io/get-pip.py python3 get-pip.py --user
          sleep 30
          pip install redis
          EOF

  depends_on = [aws_elasticache_cluster.redis]

  tags = {
    Name = "lab-bastion-redis-client"
  }
}