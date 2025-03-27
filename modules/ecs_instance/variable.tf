variable "stage" {
  type = string
}

variable "servicename" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "ami" {
  type = string
  default = "ami-0a94cc3e3653bd73c"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "ami_id" {
  type = string
}
/* 불필요 삭제
variable "security_group_id" {
  type = string
}*/

variable "instance_profile_name" {
  type = string
}

variable "key_name" {
  type = string
  default = "" # EC2 키페어 이름, 테스트 시 ""로 비워둬도 무방
}

variable "cluster_name" {
  type = string
}
