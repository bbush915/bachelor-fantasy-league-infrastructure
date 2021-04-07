output "target_group_arn" {
  value = aws_alb_target_group.api_lb_target.arn
}

output "security_group_id" {
  value = aws_security_group.api_lb_sg.id
}
