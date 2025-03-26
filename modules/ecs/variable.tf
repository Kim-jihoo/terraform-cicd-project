variable "cluster_name" {
  type    = string
}

variable "service_name" {
  type    = string
}

variable "container_image" {
  type    = string
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

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "assign_public_ip" {
  type    = bool
  default = false
}

variable "alb_listener_dependency" { #여러 리소스 고려
  type    = list(any)
  default = []
}

variable "stage" {
  type = string
}

variable "servicename" {
  type = string
}

variable "tags" {
  type = map(string)
}

