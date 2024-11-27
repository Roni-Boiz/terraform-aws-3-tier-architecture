# create internet facing application load balancer
resource "aws_lb" "internet_facing_alb" {
  name                       = "${var.project_name}-internet-facing-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.internet_facing_alb_sg_id]
  subnets                    = [var.pub_sub_1a_id, var.pub_sub_2b_id]
  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-internet-facing-alb"
  }
}
# create target group
resource "aws_lb_target_group" "web_tier_alb_tg" {
  name        = "${var.project_name}-web-tier-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 60
    path                = "/health"
    timeout             = 10
    matcher             = 200
    healthy_threshold   = 2
    unhealthy_threshold = 5
    protocol            = "HTTP"
  }

  lifecycle {
    create_before_destroy = true
  }
}
# create a listener on port 80 with redirect action
resource "aws_lb_listener" "internet_facing_alb_http_listener" {
  load_balancer_arn = aws_lb.internet_facing_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tier_alb_tg.arn
  }
}
# resource "aws_lb_target_group_attachment" "front_end" {
#   target_group_arn = aws_lb_target_group.alb_target_group.arn
#   target_id        = var.web_instance_ids
#   port             = 80
#   count = 2
# }


# create internal application load balancer
resource "aws_lb" "internal_alb" {
  name                       = "${var.project_name}-internal-alb"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [var.internal_alb_sg_id]
  subnets                    = [var.pri_sub_3a_id, var.pri_sub_4b_id]
  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-internal-alb"
  }
}
# create target group
resource "aws_lb_target_group" "app_tier_alb_tg" {
  name        = "${var.project_name}-app-tier-tg"
  target_type = "instance"
  port        = 4000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    interval            = 60
    path                = "/health"
    timeout             = 10
    matcher             = 200
    healthy_threshold   = 2
    unhealthy_threshold = 5
    protocol            = "HTTP"
  }

  lifecycle {
    create_before_destroy = true
  }
}
# create a listener on port 80 with redirect action
resource "aws_lb_listener" "internal_alb_http_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tier_alb_tg.arn
  }
}
# resource "aws_lb_target_group_attachment" "backend_end" {
#   target_group_arn = aws_lb_target_group.alb_target_group.arn
#   target_id        = var.app_instance_ids
#   port             = 80
#   count = 2
# }