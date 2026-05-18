# modules/vpc/main.tf
resource "aws_vpc" "devops_challenge_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "devops-challenge-${var.environment}-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "devops_challenge_igw" {
  vpc_id = aws_vpc.devops_challenge_vpc.id

  tags = merge(var.tags, {
    Name = "devops-challenge-${var.environment}-igw"
  })
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.devops_challenge_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "devops-challenge-${var.environment}-public-subnet-${count.index + 1}"
    Type = "Public"
  })
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.devops_challenge_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "devops-challenge-${var.environment}-private-subnet-${count.index + 1}"
    Type = "Private"
  })
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.devops_challenge_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops_challenge_igw.id
  }

  tags = merge(var.tags, {
    Name = "devops-challenge-${var.environment}-public-rt"
  })
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count  = var.enable_nat_gateway ? (var.one_nat_gateway_per_az ? length(var.availability_zones) : 1) : 0
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "devops-challenge-${var.environment}-nat-eip-${count.index + 1}"
  })
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? (var.one_nat_gateway_per_az ? length(var.availability_zones) : 1) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.tags, {
    Name = "devops-challenge-${var.environment}-nat-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.devops_challenge_igw]
}

# Private Route Tables
resource "aws_route_table" "private" {
  count  = var.enable_nat_gateway ? (var.one_nat_gateway_per_az ? length(var.availability_zones) : 1) : 1
  vpc_id = aws_vpc.devops_challenge_vpc.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index].id
    }
  }

  tags = merge(var.tags, {
    Name = "devops-challenge-${var.environment}-private-rt-${count.index + 1}"
  })
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.enable_nat_gateway ? aws_route_table.private[var.one_nat_gateway_per_az ? count.index : 0].id : aws_route_table.private[0].id
}

# Database Subnet Group
resource "aws_db_subnet_group" "database" {
  name        = "devops-challenge-${var.environment}-db-subnet-group"
  subnet_ids  = aws_subnet.private[*].id
  description = "Database subnet group for DevOps Challenge"

  tags = merge(var.tags, {
    Name = "devops-challenge-${var.environment}-db-subnet-group"
  })
}