resource "aws_s3_bucket" "terraform_state" { 
  bucket = "jihoo-terraform-state"
  force_destroy = false
}

resource "aws_s3_bucket_versioning" "enabled" { 
  bucket = aws_s3_bucket.terraform_state.id 
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" { 
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#현재 S3 버킷 퍼블릭 액세스 비활성화 되어있음
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.terraform_state.id
  block_public_acls       = false 
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "terraform_state_policy" {
  bucket = aws_s3_bucket.terraform_state.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowSpecificRole"
      Effect    = "Allow"
      Principal = { "AWS" : "arn:aws:iam::762233749320:user/jihoo.k.kuber" } #특정 IAM 사용자 지정
      Action    = [
        "s3:GetBucketPolicy",
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ]
      Resource = [
        "arn:aws:s3:::jihoo-terraform-state",
        "arn:aws:s3:::jihoo-terraform-state/*"
      ]
    }]
  })
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "jihoo-terraform-state"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}