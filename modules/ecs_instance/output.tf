output "ecs_launch_template_id" {
  value = aws_launch_template.ecs_instance.id
}

output "ecs_autoscaling_group_name" {
  value = aws_autoscaling_group.ecs_instances.name
}
