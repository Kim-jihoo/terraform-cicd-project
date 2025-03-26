output "ecs_cluster_id" {
  description = "The ID of the ECS Cluster"
  value       = aws_ecs_cluster.this.id
}

output "ecs_cluster_name" {
  description = "The name of the ECS Cluster"
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "The name of the ECS Service"
  value       = aws_ecs_service.this.name
}

output "ecs_task_definition_arn" {
  description = "The ARN of the ECS Task Definition"
  value       = aws_ecs_task_definition.this.arn
}

output "sg-ecs-id" {
  value = aws_security_group.sg-ecs.id
}

