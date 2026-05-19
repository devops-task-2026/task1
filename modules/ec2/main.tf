data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "devops_challenge_ec2" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  user_data = templatefile("${path.module}/user_data.sh", {
    environment = var.environment
  })

  tags = merge(var.tags, {
    Name = "devops-challenge-${var.environment}-ec2"
  })
}

resource "aws_eip" "devops_challenge_eip" {
  instance = aws_instance.devops_challenge_ec2.id
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "devops-challenge-${var.environment}-eip"
  })
}

resource "aws_eip_association" "devops_challenge_eip_assoc" {
  instance_id   = aws_instance.devops_challenge_ec2.id
  allocation_id = aws_eip.devops_challenge_eip.id
}