
# ========================= EC2 SECURITY=================================
#Security Group to EC2 Bastion Public Subnet
resource "aws_security_group" "bastion-sg" {
  name        = "lab-${local.name}-sg"
  vpc_id      = data.aws_vpc.vpc_selected.id
  description = "Security group for Bastion Redis cluster"
  tags = {
    label = local.label
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


# ========================= EC2 SECURITY=================================
#Security Group to EC2 private subnet
resource "aws_security_group" "server-sg" {
  name        = "lab-${local.namehostprivate}-sg"
  vpc_id      = data.aws_vpc.vpc_selected.id
  description = "Security group for server"
  tags = {
    label = local.label
  }
}

resource "aws_security_group_rule" "allow_ssh_fron_bastion" {
  security_group_id = aws_security_group.server-sg.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = aws_security_group.bastion-sg.id
}



