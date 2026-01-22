
# ========================= SECURITY PUBLIC EC2=================================
#Security Group to EC2 Bastion Public Subnet
resource "aws_security_group" "bastion-sg" {
  name        = local.name_sg_instance_bastion
  vpc_id      = data.aws_vpc.vpc_selected.id
  description = "Security group for Bastion Redis cluster"
  tags = {
    Name        = local.name_sg_instance_bastion
    environment = local.tag_environment
  }
}
#
resource "aws_security_group_rule" "allow_ssh_to_bastion" {
  security_group_id = aws_security_group.bastion-sg.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}
#
resource "aws_security_group_rule" "allow_all_from_bastion" {
  security_group_id = aws_security_group.bastion-sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}


# ========================= SECURITY PRIVATE EC2================================
#Security Group to EC2 private subnet
resource "aws_security_group" "server-sg" {
  name        = local.name_sg_instance_private
  vpc_id      = data.aws_vpc.vpc_selected.id
  description = "Security Group for Private Host"
  tags = {
    Name        = local.name_sg_instance_private
    environment = local.tag_environment
  }
}

resource "aws_security_group_rule" "allow_ssh_fron_bastion" {
  security_group_id        = aws_security_group.server-sg.id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion-sg.id
}




