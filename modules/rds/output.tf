output "rds_endpoint" {
  value = aws_db_instance.devops_challenge_rds.endpoint
}

output "rds_address" {
  value = aws_db_instance.devops_challenge_rds.address
}

output "rds_port" {
  value = aws_db_instance.devops_challenge_rds.port
}

output "rds_arn" {
  value = aws_db_instance.devops_challenge_rds.arn
}