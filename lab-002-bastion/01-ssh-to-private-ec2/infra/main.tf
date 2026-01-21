
# Bastion EC2 para criar tunuel de conexão entre o pc local ao Elasticache
# resource "aws_instance" "bastion_instance" {
#   ami                  = data.aws_ami.amzn-linux-2023-ami.id
#   instance_type        = "t2.micro"
#   subnet_id            = data.aws_subnet.public_subnet.id
#   iam_instance_profile = aws_iam_instance_profile.bastion_profile.name
#   key_name             = var.name_key_pair
#
#   vpc_security_group_ids = [
#     aws_security_group.bastion-sg.id
#   ]
#   associate_public_ip_address = true
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
#     Name = local.label
#   }
# }

resource "aws_instance" "private_instance" {
  ami                  = data.aws_ami.amzn-linux-2023-ami.id
  instance_type        = "t2.micro"
  subnet_id            = data.aws_subnet.public_subnet.id
  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name

  vpc_security_group_ids = [
    aws_security_group.server-sg.id
  ]
  associate_public_ip_address = false

  tags = {
    Name = local.label
    Host = local.namehostprivate
  }
}





