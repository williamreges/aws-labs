
resource "aws_lb" "nlb" {
  name               = "lb-app"
  internal           = false
  load_balancer_type = "network"
  subnets            = [data.aws_subnet.a.id, data.aws_subnet.c.id]
  security_groups    = [data.aws_security_group.default.id, aws_security_group.aulaaws-security-web.id]
  depends_on         = [aws_security_group.aulaaws-security-web]
}

resource "aws_apigatewayv2_vpc_link" "vpc_link" {
  name               = "vpc-link-lb-app"
  subnet_ids         = [data.aws_subnet.a.id, data.aws_subnet.c.id]
  security_group_ids = [data.aws_security_group.default.id, data.aws_security_group.web.id]
  depends_on         = [aws_lb.nlb]
}
