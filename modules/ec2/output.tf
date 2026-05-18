output "instance_id" {
  value = aws_instance.devops_challenge_ec2.id
}

output "public_ip" {
  value = aws_eip.devops_challenge_eip.public_ip
}

output "private_ip" {
  value = aws_instance.devops_challenge_ec2.private_ip
}

output "public_dns" {
  value = aws_eip.devops_challenge_eip.public_dns
}