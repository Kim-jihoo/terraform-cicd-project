##ALB

#alb log S3 버킷 추가
# ALB 로그 저장용 S3 버킷
resource "aws_s3_bucket" "alb_logs" {
  bucket = "jihoo-alb-access-logs"
  force_destroy = true

  tags = merge(tomap({
    Name = "jihoo-alb-access-logs"
  }), var.tags)
}

resource "aws_s3_bucket_ownership_controls" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "alb_logs" {
  depends_on = [aws_s3_bucket_ownership_controls.alb_logs]
  bucket     = aws_s3_bucket.alb_logs.id
  acl        = "private"
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AWSALBLogDeliveryWrite",
        Effect = "Allow",
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        },
        Action = "s3:PutObject",
        Resource = "${aws_s3_bucket.alb_logs.arn}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}


resource "aws_lb" "alb" { #alb 생성
  name               = "aws-alb-${var.stage}-${var.servicename}"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg-alb.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = true

  idle_timeout = var.idle_timeout
  depends_on = [aws_s3_bucket.alb_logs]

  access_logs {
    bucket  = var.aws_s3_lb_logs_name
    prefix  = "aws-alb-${var.stage}-${var.servicename}"
    enabled = true
  }

  tags = merge(tomap({
         Name =  "aws-alb-${var.stage}-${var.servicename}"}),
        var.tags)
}


resource "aws_lb_listener" "lb-listener-443" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

#ECS 아직 연결 안 해서 fixed-response 사용 ECS 연결 후 다시 수정
/*
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
  tags = var.tags
  depends_on =[aws_lb_target_group.target-group] #직접 참조가 있어서 생략함
}*/

default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Service not ready"
      status_code  = "503"
    }
  }

  tags = var.tags
}


resource "aws_lb_listener" "lb-listener-80" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  tags = var.tags
}


resource "aws_lb_target_group" "target-group" {
  name     = "aws-alb-tg-${var.stage}-${var.servicename}"
  port     = var.port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  #target_type = var.target_type
  target_type = "ip" # ECS와 연동할 것이므로 IP 기반
  health_check {
    path = var.hc_path
    healthy_threshold   = var.hc_healthy_threshold
    unhealthy_threshold = var.hc_unhealthy_threshold
  }
  tags = merge(tomap({
         Name =  "aws-alb-tg-${var.stage}-${var.servicename}"}),
        var.tags)
}

# target_group_attachment는 ECS가 자동으로 연결하므로 삭제
/*
resource "aws_lb_target_group_attachment" "target-group-attachment" {
  count = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.target-group.arn
  target_id        = var.instance_ids[count.index]
  port             = var.port
  
  availability_zone = var.availability_zone
  
  depends_on =[aws_lb_target_group.target-group]
}*/

#alb sg
resource "aws_security_group" "sg-alb" {
  name   = "aws-sg-${var.stage}-${var.servicename}-alb"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = var.sg_allow_comm_list
    description = ""
    #self        = true cidr과 self 동시에 쓰면 충돌날 수 있음
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = var.sg_allow_comm_list
    description = ""
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(tomap({
         Name = "aws-sg-${var.stage}-${var.servicename}-alb"}), 
        var.tags)
}

resource "aws_security_group" "sg-alb-to-tg" {
  name   = "aws-sg-${var.stage}-${var.servicename}-alb-to-tg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "TCP"
    security_groups = [aws_security_group.sg-alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(tomap({
         Name = "aws-sg-${var.stage}-${var.servicename}-alb-to-tg"}), 
        var.tags)
}

resource "aws_route53_record" "alb-record" {
  count = var.domain != "" ? 1:0
  zone_id = var.hostzone_id
  name    = "${var.stage}-${var.servicename}.${var.domain}"
  type    = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}