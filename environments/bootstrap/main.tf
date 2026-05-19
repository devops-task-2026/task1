terraform {
  required_version = ">= 1.5.0"
  
  backend "local" {
    path = "terraform.tfstate"
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

locals {
  environments = ["dev", "staging", "prod"]
  
  common_tags = {
    Project     = "DevOps-Challenge"
    ManagedBy   = "Terraform"
    Component   = "Terraform-Backend"
    CreatedBy   = "Bootstrap"
  }
}

resource "aws_s3_bucket" "terraform_state" {
  for_each = toset(local.environments)
  
  bucket = "christian-devops-challenge-tfstate-${each.key}"
  force_destroy = true
  
  tags = merge(local.common_tags, {
    Name        = "terraform-state-${each.key}"
    Environment = each.key
  })
}

# Enable versioning for all buckets
resource "aws_s3_bucket_versioning" "terraform_state" {
  for_each = toset(local.environments)
  
  bucket = aws_s3_bucket.terraform_state[each.key].id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption for all buckets
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  for_each = toset(local.environments)
  
  bucket = aws_s3_bucket.terraform_state[each.key].id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access for all buckets
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  for_each = toset(local.environments)
  
  bucket = aws_s3_bucket.terraform_state[each.key].id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create DynamoDB tables for state locking
resource "aws_dynamodb_table" "terraform_lock" {
  for_each = toset(local.environments)
  
  name         = "devops-challenge-tfstate-lock-${each.key}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  tags = merge(local.common_tags, {
    Name        = "terraform-lock-${each.key}"
    Environment = each.key
  })
}

# Outputs
output "bucket_names" {
  description = "Names of created S3 buckets"
  value = {
    for env in local.environments :
    env => aws_s3_bucket.terraform_state[env].id
  }
}

output "dynamodb_tables" {
  description = "Names of created DynamoDB tables"
  value = {
    for env in local.environments :
    env => aws_dynamodb_table.terraform_lock[env].name
  }
}

output "bootstrap_complete" {
  description = "Bootstrap completion message"
  value = "✅ Bootstrap complete! Resources created in ap-northeast-1"
}
