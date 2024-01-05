locals {

}

resource "aws_lb" "nova_alb" {
  name                       = "nova-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = module.vpc.public_subnets
  enable_deletion_protection = false

  enable_cross_zone_load_balancing = true

  tags = {
    Name = "nova-alb"
  }
}

resource "aws_lb_target_group" "nova-tgs" {
  for_each    = local.services
  name        = "${each.key}-tg"
  port        = each.value.target_group_port
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  health_check {
    enabled             = true
    interval            = 30
    path                = "/${each.key}"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"

  }
}

resource "aws_lb_listener" "nova_front" {
  load_balancer_arn = aws_lb.nova_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "nova-listeners-rules" {
  for_each     = local.services
  listener_arn = aws_lb_listener.nova_front.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nova-tgs[each.key].arn
  }

  condition {
    path_pattern {
      values = ["/${each.key}*"]
    }
  }
}