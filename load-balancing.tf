resource "aws_lb" "my-lb" {
  name               = "my-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = ["subnet-id1", "subnet-id2"]

  tags = {
    "Name" = "my-lb"
  }
}

resource "aws_lb_target_group" "test" {
  name     = "tg-01"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0461dca8d64e8c79d"
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.my-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test.arn
  }
}
