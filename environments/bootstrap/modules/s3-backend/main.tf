# bootstrap/modules/s3-backend/main.tf
# Reusable module for creating S3 backend infrastructure

# S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name
  
  # Prevent accidental deletion of state bucket
  force_destroy = var.environment != "prod"  # Production buckets are protected
  
  tags = merge(var.tags, {
    Name        = "terraform-state-${var.environment}"
    Environment = var.environment
  })
}

# Bucket Versioning (Critical for state recovery)
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block Public Access (Security Best Practice)
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket Policy for Security
resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = data.aws_iam_policy_document.secure_bucket.json
}

data "aws_iam_policy_document" "secure_bucket" {
  statement {
    sid    = "EnforceTLS"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
  
  statement {
    sid    = "DenyIncorrectEncryptionHeader"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["AES256"]
    }
  }
}

# DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_lock" {
  name         = var.dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  # Point-in-time recovery for production
  point_in_time_recovery {
    enabled = var.environment == "prod"
  }
  
  tags = merge(var.tags, {
    Name        = "terraform-lock-${var.environment}"
    Environment = var.environment
  })
  
  # Prevent accidental deletion of lock table
  lifecycle {
    prevent_destroy = var.environment == "prod"
  }
}

# CloudWatch Alarm for Bucket Access (Security Monitoring)
resource "aws_cloudwatch_metric_alarm" "bucket_access" {
  count = var.environment == "prod" ? 1 : 0
  
  alarm_name          = "terraform-state-bucket-access-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name        = "NumberOfObjects"
  namespace          = "AWS/S3"
  period             = 3600
  statistic          = "Sum"
  threshold          = 1000
  alarm_description  = "Alert if number of objects in state bucket exceeds 1000"
  
  dimensions = {
    BucketName = aws_s3_bucket.terraform_state.id
    StorageType = "AllStorageTypes"
  }
}