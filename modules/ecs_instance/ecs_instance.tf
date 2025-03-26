resource "aws_launch_template" "ecs_instance" {
  name_prefix   = "ecs-instance-${var.stage}-${var.servicename}-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  iam_instance_profile {
    name = var.instance_profile_name
  }
  key_name = var.key_name
  user_data = base64encode(<<EOF
#!/bin/bash
echo ECS_CLUSTER=${var.cluster_name} >> /etc/ecs/ecs.config
systemctl enable --now ecs
EOF
)


  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.security_group_ids[0]]
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge({
      Name = "ecs-instance-${var.stage}-${var.servicename}"
    }, var.tags)
  }
}

resource "aws_autoscaling_group" "ecs_instances" {
  name_prefix          = "asg-ecs-${var.stage}-${var.servicename}-"
  max_size             = 1
  min_size             = 1
  desired_capacity     = 1
  vpc_zone_identifier  = var.subnet_ids
  launch_template {
    id      = aws_launch_template.ecs_instance.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "ecs-instance-${var.stage}-${var.servicename}"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}
