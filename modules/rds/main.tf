# modules/rds/main.tf
# Generate random password if not provided (for automation)
resource "random_password" "db_password" {
  count = var.db_password == "" ? 1 : 0

  length           = 16
  special          = true
  override_special = "!#$%&*?"
}

# RDS Instance
resource "aws_db_instance" "devops_challenge_rds" {
  identifier = "devops-challenge-${var.environment}-db"

  engine         = "postgres"
  engine_version = "15"
  instance_class = var.instance_class

  db_name = var.db_name
  username      = var.db_username
  password      = var.db_password != "" ? var.db_password : random_password.db_password[0].result

  # Storage configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  # Network configuration
  vpc_security_group_ids = [var.security_group_id]
  db_subnet_group_name   = var.db_subnet_group_name
  publicly_accessible    = false

  # Backup configuration
  backup_retention_period = var.backup_retention_period
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  # High availability for production
  multi_az = var.multi_az

  # Deletion protection for production
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  tags = merge(var.tags, {
    Name = "devops-challenge-${var.environment}-rds"
  })
}