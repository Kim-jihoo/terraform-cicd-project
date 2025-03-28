variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution for OAC policy"
  type        = string
}
