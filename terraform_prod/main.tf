terraform {
 required_version = ">= 1.0.0, < 2.0.0"

  backend "s3" {
    bucket = "jihoo-terraform-state"
    key  = "prod/terraform/terraform.tfstate"
    region = "ap-northeast-2"
    encrypt = true
    dynamodb_table = "jihoo-terraform-state"
  }
}

##Sharedservic resources
module "vpc" {
  source              = "../modules/vpc"

  stage       = var.stage
  servicename = var.servicename
  tags        = var.tags
  # region     = var.region
  # kms_arn = var.s3_kms_key_id

  vpc_ip_range = var.vpc_ip_range
  az           = var.az

  subnet_public_az1 = var.subnet_public_az1
  subnet_public_az2 = var.subnet_public_az2
  subnet_service_az1 = var.subnet_service_az1
  subnet_service_az2 = var.subnet_service_az2
  subnet_db_az1  = var.subnet_db_az1
  subnet_db_az2  = var.subnet_db_az2
 

 
  ##SecurityGroup
  #sg_allow_comm_list = concat(var.ext_sg_allow_list, ["${module.vpc.nat_ip}/32", var.vpc_ip_range])

  ##TGW
  #create_tgw = var.create_tgw
  #tgw_sharing_accounts = var.tgw_sharing_accounts
#   ext_vpc_route = var.ext_vpc_route
  #security_attachments = var.security_attachments
  #auto_accept_shared_attachments = true
  #security_attachments_propagation = merge(var.security_attachments_propagation, var.security_attachments)
}

#ALB
module "alb" {
  source = "../modules/alb"

  stage       = var.stage
  servicename = var.servicename
  tags        = var.tags

  vpc_id     = module.vpc.vpc_id
  subnet_ids = [module.vpc.service-az1.id, module.vpc.service-az2.id]

  sg_allow_comm_list   = var.sg_allow_comm_list
  aws_s3_lb_logs_name  = var.aws_s3_lb_logs_name
  idle_timeout         = var.idle_timeout
  certificate_arn      = var.certificate_arn
  port                 = var.port
  domain               = var.domain
  hostzone_id          = var.hostzone_id
  hc_path              = var.hc_path
  hc_healthy_threshold = var.hc_healthy_threshold
  hc_unhealthy_threshold = var.hc_unhealthy_threshold
}

# ECS
module "ecs" {
  source = "../modules/ecs"

  stage       = var.stage
  servicename = var.servicename
  tags        = var.tags

  cluster_name        = "ecs-cluster-${var.stage}-${var.servicename}"
  service_name        = "ecs-service-${var.stage}-${var.servicename}"
  container_image     = var.container_image
  container_port      = var.container_port
  cpu                 = var.cpu
  memory              = var.memory
  subnet_ids          = [module.vpc.service-az1.id, module.vpc.service-az2.id]
  vpc_id              = module.vpc.vpc_id
  alb_sg_id           = module.alb.sg-alb-id
  security_group_ids  = [] # 보안 그룹 직접 생성되므로 이 필드는 사용되지 않음
  target_group_arn    = module.alb.target-group-arn
  execution_role_arn  = var.execution_role_arn
  task_role_arn       = var.task_role_arn
  desired_count       = var.desired_count
  assign_public_ip    = false
  #alb_listener_dependency = [module.alb.lb-listener-443]
  alb_listener_dependency = var.certificate_arn != "" ? [module.alb.lb-listener-443[0]] : [] #certificate_arn이 비어있을 때

}
# ecs_instance
module "ecs_instance" {
  source = "../modules/ecs_instance"

  stage                = var.stage
  servicename          = var.servicename
  tags                 = var.tags
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  subnet_ids           = [module.vpc.service-az1.id, module.vpc.service-az2.id]
  security_group_ids = [module.ecs.sg-ecs-id]
  instance_profile_name = "ecsInstanceRole" # 사전에 생성해둔 EC2용 IAM 역할
  key_name             = var.key_name
  cluster_name         = module.ecs.ecs_cluster_name
}

#RDS 시간 너무 오래 걸려서 일단 주석
/*
 module "rds" {
  source       = "../modules/aurora"
  stage        = var.stage
  servicename  = var.servicename
  tags         = var.tags
  dbname       = var.rds_dbname

  sg_allow_ingress_list_aurora = var.sg_allow_ingress_list_aurora
  network_vpc_id               = module.vpc.vpc_id
  subnet_ids                   = [module.vpc.db-az1.id, module.vpc.db-az2.id]
  az                           = var.az

  rds_instance_count = var.rds_instance_count
  kms_key_id         = var.rds_kms_arn
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  sg_allow_ingress_sg_list_aurora = var.sg_allow_ingress_sg_list_aurora
  depends_on = [module.vpc]
}*/
module "frontend_cloudfront" {
  source                   = "../modules/cloudfront_static"
  tags                     = var.tags
  default_root_object      = "index.html"
  error_page               = "error.html"
  s3_bucket_id             = module.frontend_s3.s3_bucket_id 
  s3_bucket_domain_name    = "jihoo-frontend-static-prod.s3.ap-northeast-2.amazonaws.com" # 또는 output 참조 가능
  s3_origin_id             = "frontend-s3-origin"  # 자유롭게 설정 가능
  viewer_certificate_acm_arn = "" # 기본 인증서 사용할 경우 생략 가능
  domain_alias             = ""  # 커스텀 도메인 없으면 생략
}

module "frontend_s3" {
  source                      = "../modules/s3_static"
  bucket_name                 = "jihoo-frontend-static-prod"
  tags                        = var.tags
  cloudfront_distribution_arn = "arn:aws:cloudfront::${var.aws_account_id}:distribution/${module.frontend_cloudfront.cloudfront_distribution_id}"
}

# Route53
resource "aws_route53_record" "frontend" {
  zone_id = var.hostzone_id
  name    = "jihoo.click"
  type    = "A"

  alias {
    name                   = module.frontend_cloudfront.cloudfront_domain_name
    zone_id                = module.frontend_cloudfront.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}



# module "jihoo-ec2" {
#   source              = "../modules/instance"

#   stage        = var.stage
#   servicename  = "${var.servicename}"
#   tags         = var.tags

#   ami                       = var.ami
#   instance_type             = var.instance_type
#   ebs_size                  = var.instance_ebs_size
#   #user_data                 = var.instance_user_data
#   kms_key_id                = var.ebs_kms_key_id
#   ec2-iam-role-profile-name = module.iam-service-role.ec2-iam-role-profile.name
#   ssh_allow_comm_list       = [var.subnet_service_az1, var.subnet_service_az2]

#   associate_public_ip_address = var.associate_public_ip_address

#   subnet_id = module.vpc.public-az1.id
#   vpc_id    = module.vpc.vpc_id
#   user_data = <<-EOF
# #!/bin/bash 
# yum update -y 
# yum install -y https://s3.ap-northeast-2.amazonaws.com/amazon-ssm-ap-northeast-2/latest/linux_amd64/amazon-ssm-agent.rpm
# EOF
#   ##SecurityGroup
#   sg_ec2_ids = [aws_security_group.sg-ec2.id]
#   #depends_on = [module.vpc.sg-ec2-comm, module.iam-service-role.ec2-iam-role-profile]
# }

# resource "aws_security_group" "sg-ec2" {
#   name   = "aws-sg-${var.stage}-${var.servicename}-ec2"
#   vpc_id = module.vpc.vpc_id

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "TCP"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = ""
#   }
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "TCP"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = ""
#   }
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "TCP"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = ""
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = merge(tomap({
#          Name = "aws-sg-${var.stage}-${var.servicename}-ec2"}), 
#         var.tags)
# }



