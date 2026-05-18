output "ec2_security_group_id" {
  value = aws_security_group.devops_challenge_ec2_sg.id
}

output "rds_security_group_id" {
  value = aws_security_group.devops_challenge_rds_sg.id
}