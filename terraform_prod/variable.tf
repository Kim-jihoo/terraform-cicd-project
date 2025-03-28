variable "region" {
  type = string
  default = "ap-northeast-2"
}
variable "stage" {
  type = string
  default = "prod"
}
variable "servicename" {
  type = string
  default = "terraform-jihoo"
}
variable "tags" {
  type = map(string)
  default = {
    "name" = "jihoo_VPC"
  }
}

#VPC
variable "az" {
  type = list(any)
  default = [ "ap-northeast-2a", "ap-northeast-2c" ]
}
variable "vpc_ip_range" {
  type = string
  default = "10.2.93.0/24"
}

variable "subnet_public_az1" {
  type = string
  default = "10.2.93.0/27"
}
variable "subnet_public_az2" {
  type = string
  default = "10.2.93.32/27"
}
variable "subnet_service_az1" {
  type = string
  default = "10.2.93.64/26"
}
variable "subnet_service_az2" {
  type = string
  default = "10.2.93.128/26"
}
variable "subnet_db_az1" {
  type = string
  default = "10.2.93.192/27"
}
variable "subnet_db_az2" {
  type = string
  default = "10.2.93.224/27"
}
# variable "create_tgw" {
#   type = bool
#   default = false
# }
# variable "ext_vpc_route" {
#   type = any
# }
# variable "security_attachments" {
#   type = any
# }
# variable "security_attachments_propagation" {
#   type = any
# }
# variable "tgw_sharing_accounts" {
#   type = map
# }

#ALB
variable "aws_s3_lb_logs_name" {
  type = string
  default = "jihoo-alb-access-logs"
}

variable "idle_timeout" {
  type    = string
  default = "60"
}

variable "certificate_arn" {
  type = string
  default = "" # ACM에서 발급받은 인증서 ARN
}

variable "domain" {
  type    = string
  default = "" # ex: example.com
}


variable "port" {
  type    = string
  default = "80"
}

variable "hc_path" {
  type    = string
  default = "/"
}

variable "hc_healthy_threshold" {
  type    = number
  default = 5
}

variable "hc_unhealthy_threshold" {
  type    = number
  default = 2
}
variable "sg_allow_comm_list" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}


##Instance
/* ami_id와 중복으로 제거
variable "ami"{
  type = string
  default = "ami-04c596dcf23eb98d8"
}*/
variable "instance_type" {
  type = string
  default = "t2.micro"
}
variable "instance_ebs_size" {
  type = number
  default = 20
}
variable "instance_ebs_volume" {
  type = string
  default = "gp3"
}

# variable "instance_user_data" {
#   type = string
# }
# variable "redis_endpoints" {
#   type = list
# }

##RDS
variable "rds_dbname" {
  type = string
  default = "jihoo"
}
variable "rds_instance_count" {
  type = string
  default = "2"
}
variable "sg_allow_ingress_list_aurora"{
  type = list
  default = ["10.2.92.64/26", "10.2.92.128/26", "10.2.92.18/32"]
}
variable "associate_public_ip_address" {
  type = bool
  default = true
}

##KMS
variable "rds_kms_arn" {
  type    = string
  default = "arn:aws:kms:ap-northeast-2:762233749320:key/32436012-6187-473c-8449-3a4d90b6d73c"
}
variable "ebs_kms_key_id" {
  type = string
  default = "arn:aws:kms:ap-northeast-2:471112992234:key/43b0228d-0a06-465c-b25c-7480b07b5276"
}

# ECS
variable "container_image" {
  type    = string
  default = "nginx:latest"
}

variable "execution_role_arn" {
  type = string
  default = "arn:aws:iam::762233749320:role/ecsTaskExecutionRole"
}


variable "task_role_arn" {
  type    = string
  default = "arn:aws:iam::762233749320:role/ecsTaskRole"
}


variable "container_port" {
  type    = number
  default = 80
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "desired_count" {
  type    = number
  default = 1
}

# ecs_instance
variable "ami_id" {
  type    = string
  default = "ami-0a07a3809aa66dcac"
}

variable "key_name" {
  type    = string
  default = "" # 실제 EC2에 접근하려면 EC2 키페어 이름을 여기에 넣어야 합니다
}
variable "sg_allow_ingress_sg_list_aurora" {
  type    = list(string)
  default = []
}
# CloudFront용 변수
variable "s3_bucket_domain_name" {
  description = "The domain name of the S3 bucket used as CloudFront origin"
  type        = string
  default     = "jihoo-frontend-static-prod.s3.ap-northeast-2.amazonaws.com"
}

variable "s3_origin_id" {
  description = "The unique origin ID used in CloudFront distribution"
  type        = string
  default     = "frontend-s3-origin"
}
variable "aws_account_id" {
  type        = string
  description = "AWS 계정 ID"
  default     = "762233749320"
}

variable "hostzone_id" {
  type    = string
  default = "Z0081242AVNDKVPTQC93"
}
variable "viewer_certificate_acm_arn" {
  type    = string
  default = "arn:aws:acm:us-east-1:762233749320:certificate/c630bd43-78e6-4d0a-b9e1-3c10f21eb28b"
}

