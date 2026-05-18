output "ec2_public_ip" {
  value = module.ec2.public_ip
}

output "ec2_public_dns" {
  value = module.ec2.public_dns
}

output "rds_endpoint" {
  value     = module.rds.rds_endpoint
  sensitive = true
}

output "ssh_command" {
  value = "ssh -i devops-challenge-staging-key.pem ec2-user@${module.ec2.public_ip}"
}