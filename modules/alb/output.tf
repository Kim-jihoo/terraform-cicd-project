output "sg_alb_to_tg_id" {
  value = aws_security_group.sg-alb-to-tg.id
}
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}
output "alb_zone_id" {
  value = aws_lb.alb.zone_id
}
output "sg-alb-id" {
  value = aws_security_group.sg-alb.id
}

output "target-group-arn" {
  value = aws_lb_target_group.target-group.arn
}

output "lb-listener-443" {
  value = aws_lb_listener.lb-listener-443.id
}
