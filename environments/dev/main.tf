# environments/dev/main.tf
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  environment = "dev"

  # Development CIDR blocks
  vpc_cidr = "10.0.0.0/16"

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnets = [
    "10.0.10.0/24",
    "10.0.20.0/24"
  ]

  availability_zones = [
    "ap-northeast-1a",
    "ap-northeast-1c"
  ]

  # Development specifications
  ec2_instance_type     = "t3.micro"
  rds_instance_class    = "db.t3.micro"
  rds_allocated_storage = 20
  rds_backup_retention  = 1

  common_tags = {
    Environment = "development"
    Project     = "DevOps-Challenge"
    ManagedBy   = "Terraform"
  }
}

# Create Key Pair automatically
resource "tls_private_key" "devops_challenge_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "devops_challenge_key" {
  key_name   = var.key_name
  public_key = tls_private_key.devops_challenge_key.public_key_openssh
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr             = local.vpc_cidr
  public_subnet_cidrs  = local.public_subnets
  private_subnet_cidrs = local.private_subnets
  availability_zones   = local.availability_zones
  environment          = local.environment
  enable_nat_gateway   = false # Dev doesn't need NAT

  tags = local.common_tags
}

# Security Module
module "security" {
  source = "../../modules/security"

  vpc_id            = module.vpc.vpc_id
  environment       = local.environment
  allowed_ssh_cidrs = ["0.0.0.0/0"] # Dev allows all SSH

  tags = local.common_tags
}

# EC2 Module
module "ec2" {
  source = "../../modules/ec2"

  environment       = local.environment
  instance_type     = local.ec2_instance_type
  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.security.ec2_security_group_id
  key_name          = aws_key_pair.devops_challenge_key.key_name

  tags = local.common_tags
}

# RDS Module
module "rds" {
  source = "../../modules/rds"

  environment          = local.environment
  instance_class       = local.rds_instance_class
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  security_group_id    = module.security.rds_security_group_id
  db_subnet_group_name = module.vpc.database_subnet_group_name

  allocated_storage       = local.rds_allocated_storage
  backup_retention_period = local.rds_backup_retention
  multi_az                = false # Dev is single AZ
  deletion_protection     = false # Dev allows deletion
  skip_final_snapshot     = true  # Dev doesn't need snapshots

  tags = local.common_tags
}

resource "local_file" "private_key" {
  content         = tls_private_key.devops_challenge_key.private_key_pem
  filename        = "${path.module}/keys/devops-challenge-dev-key.pem"
  file_permission = "0400"
}