resource "aws_security_group" "devops_challenge_ec2_sg" {
  name        = "devops-challenge-${var.environment}-ec2-sg"
  description = "Security group for DevOps Challenge EC2 instance"
  vpc_id      = var.vpc_id

  # SSH access - restricted to specific CIDRs for security
  ingress {
    description     = "SSH from allowed networks"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = var.allowed_ssh_cidrs
  }

  # HTTP access
  ingress {
    description     = "HTTP from anywhere"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    description     = "HTTPS from anywhere"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  # Outbound internet access
  egress {
    description     = "Outbound internet"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "devops-challenge-${var.environment}-ec2-sg"
  })
}

# Security Group for RDS
resource "aws_security_group" "devops_challenge_rds_sg" {
  name        = "devops-challenge-${var.environment}-rds-sg"
  description = "Security group for DevOps Challenge RDS"
  vpc_id      = var.vpc_id

  # PostgreSQL access from EC2 security group only
  ingress {
    description     = "PostgreSQL from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.devops_challenge_ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "devops-challenge-${var.environment}-rds-sg"
  })
}