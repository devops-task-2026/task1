# modules/ec2/main.tf
# Get the latest Amazon Linux 2 AMI
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

# EC2 Instance
resource "aws_instance" "devops_challenge_ec2" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  # User data script to set up web server
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>DevOps Challenge - ${var.environment} Environment</h1>" > /var/www/html/index.html
    echo "<p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>" >> /var/www/html/index.html
    echo "<p>Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>" >> /var/www/html/index.html
    EOF

  tags = merge(var.tags, {
    Name = "devops-challenge-${var.environment}-ec2"
  })
}

# Elastic IP for the EC2 instance
resource "aws_eip" "devops_challenge_eip" {
  instance = aws_instance.devops_challenge_ec2.id
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "devops-challenge-${var.environment}-eip"
  })
}