resource "aws_ecs_cluster" "this" { #이후에 this 수정(리소스 많아지거나 여러 ecs 사용하면)
  name = "ecs-cluster-${var.stage}-${var.servicename}"
  tags = var.tags
}

resource "aws_ecs_task_definition" "this" {
  family                   = "ecs-task-${var.stage}-${var.servicename}"
  requires_compatibilities = ["EC2"]
  network_mode            = "bridge"
  cpu                     = var.cpu
  memory                  = var.memory
  execution_role_arn      = var.execution_role_arn
  task_role_arn           = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "${var.servicename}"
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
    }
  ])

  tags = var.tags
}

resource "aws_ecs_service" "this" {
  name            = "ecs-service-${var.stage}-${var.servicename}"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "EC2"
  desired_count   = var.desired_count

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.servicename
    container_port   = var.container_port
  }

  depends_on = var.alb_listener_dependency

  tags = var.tags
}
