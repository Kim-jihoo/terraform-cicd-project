resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  default_root_object = var.default_root_object
  aliases             = ["jihoo.click", "www.jihoo.click"]

  origin {
    domain_name = var.s3_bucket_domain_name
    origin_id   = var.s3_origin_id

    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
    s3_origin_config {
      origin_access_identity = ""
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    acm_certificate_arn      = var.viewer_certificate_acm_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = var.tags
}
