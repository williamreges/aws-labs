

resource "aws_lb_target_group" "tg_app" {
  name            = "tg-app"
  port            = 80
  protocol        = "HTTP"
  vpc_id          = data.aws_vpc.default.id
  ip_address_type = "ipv4"
  target_type     = "ip"

  depends_on = [aws_lb.nlb]
}