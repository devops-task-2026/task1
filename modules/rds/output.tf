output "rds_endpoint" {
  value = aws_db_instance.devops_challenge_rds.endpoint
}

output "rds_db_name" {
  value = aws_db_instance.devops_challenge_rds.db_name
}

output "rds_username" {
  value = aws_db_instance.devops_challenge_rds.username
}

output "rds_port" {
  value = aws_db_instance.devops_challenge_rds.port
}

output "rds_instance_id" {
  value = aws_db_instance.devops_challenge_rds.id
}