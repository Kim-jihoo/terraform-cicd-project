variable "s3_bucket_id" {
  description = "ID of the S3 bucket used as origin"
  type        = string
}

variable "tags" {
  description = "Tags to apply to CloudFront resources"
  type        = map(string)
}

variable "viewer_certificate_acm_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
}

variable "domain_alias" {
  description = "Custom domain name (e.g., frontend.example.com)"
  type        = string
}

variable "default_root_object" {
  description = "Default root object for the distribution"
  type        = string
  default     = "index.html"
}

variable "error_page" {
  description = "Custom error page (e.g., error.html)"
  type        = string
  default     = "error.html"
}
variable "s3_bucket_domain_name" {
  description = "The domain name of the S3 bucket (used as origin)"
  type        = string
}

variable "s3_origin_id" {
  description = "A unique ID to identify the origin in CloudFront"
  type        = string
}
variable "waf_web_acl_id" {
  type        = string
  description = "WAF Web ACL ARN"
  default     = null
}
