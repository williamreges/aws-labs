

# ==== Create a VPC ===============
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "vpc-${local.tag_enviromnent}"
  }
}

# ==== Create Internet Gateway ===========
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "gtw-${local.tag_enviromnent}"
  }
}

# ==== Create Router Public ================
resource "aws_route_table" "router-public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "router-public-${local.tag_enviromnent}"
  }
}

resource "aws_route_table" "router-private" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "router-private-${local.tag_enviromnent}"
  }
}

#================== AZ PRIVADO ===================
# Create Privatte Subnet
resource "aws_subnet" "private-subnet" {
  for_each = var.private-subnets

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.key
  }
}

# ==== Assicie ao router table privado
resource "aws_route_table_association" "associate_route_table_private" {
  for_each       = aws_subnet.private-subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.router-private.id
}
#================= AZ PUBLIC ====================

# Create Public Subnet
resource "aws_subnet" "public-subnet" {
  for_each = var.public-subnets

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = each.key
  }
}

resource "aws_route_table_association" "associate_route_table_public" {
  for_each       = aws_subnet.public-subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.router-public.id
}


# =============== CREATE SECURITY GROUP ===============================
# Create Security Group
resource "aws_security_group" "lab_sg_default" {
  name        = "sg_default-${local.tag_enviromnent}"
  description = "Allow WEB inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "sg_default_${local.tag_enviromnent}"
  }
}

# Create Ingress Rule SSH
resource "aws_vpc_security_group_ingress_rule" "allow_from_sg_default" {
  security_group_id = aws_security_group.lab_sg_default.id
  from_port         = 0
  ip_protocol       = "-1"
  to_port           = 0
  referenced_security_group_id = aws_security_group.lab_sg_default.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.lab_sg_default.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

