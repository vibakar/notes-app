output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "app_url" {
  value = aws_route53_record.alb_cname.name
}

output "alb_arn" {
  value = aws_lb.app_alb.arn
}

output "blue_tg_arn" {
  value = aws_lb_target_group.frontend_blue_tg.arn
}

output "green_tg_arn" {
  value = aws_lb_target_group.frontend_green_tg.arn
}

output "blue_listener_arn" {
  value = aws_lb_listener.frontend_blue.arn
}

output "green_listener_arn" {
  value = aws_lb_listener.frontend_green.arn
}
