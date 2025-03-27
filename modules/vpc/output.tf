output "db-az1" {
  value = aws_subnet.db-az1
}

output "db-az2" {
  value = aws_subnet.db-az2
}

output "network-vpc" {
  value = aws_vpc.aws-vpc
}

output "public-az1" {
  value = aws_subnet.public-az1
}
output "public-az2" {
  value = aws_subnet.public-az2
}
output "service-az1" {
  value = aws_subnet.service-az1
}

output "service-az2" {
  value = aws_subnet.service-az2
}

# # Fowler - Merge이후 주석 삭제
# output "db-sg-gitlab" {
#   value = aws_security_group.sg-allow-postgres-ingress.id
# }
# # Fowler - Merge이후 주석 삭제
# output "db-subnet-group-gitlab"{
#   value = aws_db_subnet_group.db-subnet-group-gitlab.id
# }
# # Fowler - Merge이후 주석 삭제
# output "redis-subnet-group-gitlab"{
#   value = aws_elasticache_subnet_group.redis-subnet-group-gitlab.id
# }

output "vpc_id" {
  value = aws_vpc.aws-vpc.id
}
output "vpc_cidr" {
  value = aws_vpc.aws-vpc.cidr_block
}
output "nat_ip_az1" {
  value = aws_eip.nat-eip-az1.public_ip
}
output "nat_ip_az2" {
  value = aws_eip.nat-eip-az2.public_ip
}

output "nat_id_az1" {
  value = aws_nat_gateway.vpc-nat-az1.id
}
output "nat_id_az2" {
  value = aws_nat_gateway.vpc-nat-az2.id
}

output "pri_rt_az1_id" {
  value = aws_route_table.aws-rt-pri-az1.id
}
output "pri_rt_az2_id" {
  value = aws_route_table.aws-rt-pri-az2.id
}

output "db_subnet_ids" {
  value = [
    aws_subnet.db-az1.id,
    aws_subnet.db-az2.id
  ]
}
