output "web_tier_alb_tg_arn" {
  value = aws_lb_target_group.web_tier_alb_tg.arn
}

output "app_tier_alb_tg_arn" {
  value = aws_lb_target_group.app_tier_alb_tg.arn
}

output "internet_facing_alb_dns_name" {
  value = aws_lb.internet_facing_alb.dns_name
}

output "internal_alb_dns_name" {
  value = aws_lb.internal_alb.dns_name
}