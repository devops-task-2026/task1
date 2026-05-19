output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.ec2.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = module.ec2.public_dns
}

output "rds_endpoint" {
  description = "PostgreSQL RDS endpoint"
  value       = module.rds.rds_endpoint
}

output "rds_port" {
  description = "PostgreSQL port"
  value       = module.rds.rds_port
}

output "rds_database_name" {
  description = "Database name"
  value       = module.rds.rds_db_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "ssh_command" {
  description = "SSH command to connect to EC2"
  value       = "ssh -i devops-challenge-dev-key.pem ec2-user@${module.ec2.public_ip}"
}