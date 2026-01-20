resource "aws_security_group" "aulaaws-security-web" {
  name        = "aulaaws-security-web"
  description = "Security group allowing port 80 from itself"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow HTTP from resources with this SG"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = true
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-sg"
  }
}