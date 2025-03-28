output "s3_bucket_id" {
  value = aws_s3_bucket.frontend.id
}

output "s3_bucket_website_endpoint" {
  value = aws_s3_bucket.frontend.website_endpoint
}
