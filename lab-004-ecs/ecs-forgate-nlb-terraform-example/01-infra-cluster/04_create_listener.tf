


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_app.arn
  }

  depends_on = [
    aws_lb.nlb,
    aws_lb_target_group.tg_app
  ]
}
