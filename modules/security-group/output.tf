output "internet_facing_alb_sg_id" {
  value = aws_security_group.internet_facing_alb_sg.id
}

output "web_tier_sg_id" {
  value = aws_security_group.web_tier_sg.id
}

output "internal_alb_sg_id" {
  value = aws_security_group.internal_alb_sg.id
}

output "app_tier_sg_id" {
  value = aws_security_group.app_tier_sg.id
}

output "db_tier_sg_id" {
  value = aws_security_group.db_tier_sg.id
}