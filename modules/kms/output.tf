output "eks_kms_arn" { #eks 클러스터용 키
  value =aws_kms_key.eks-kms-key.arn
}
output "rds_kms_arn" {
  value =aws_kms_key.rds-kms-key.arn
}
output "ssm_parameter_kms_arn" { #ssm secureString 암호화 키
  value =aws_kms_key.ssm-parameter-kms-key.arn
}