# infra/modules/network/main.tf

locals {
  azs = slice(var.azs, 0, 2) # nos quedamos con las 2 primeras AZs
}

# ───── VPC ─────
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "${var.project}-vpc" }
}

# ───── Subnets PÚBLICAS (ALB + NAT viven aquí) ─────
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index) # 10.20.0.0/24, 10.20.1.0/24
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.project}-public-${count.index}" }
}

# ───── Subnets PRIVADAS (EC2/Fargate/RDS viven aquí) ─────
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10) # 10.20.10.0/24, 10.20.11.0/24
  availability_zone = local.azs[count.index]
  tags              = { Name = "${var.project}-private-${count.index}" }
}

# ───── Internet Gateway ─────
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project}-igw" }
}

# ───── Elastic IP para el NAT ─────
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]
  tags       = { Name = "${var.project}-nat-eip" }
}

# ───── NAT Gateway (single-AZ a propósito para abaratar) ─────
# Tradeoff: si cae us-east-1a, las privadas pierden egreso. Documentado en reporte.
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "${var.project}-nat" }
  depends_on    = [aws_internet_gateway.this]
}

# ───── Route Tables ─────
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = { Name = "${var.project}-rt-public" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
  tags = { Name = "${var.project}-rt-private" }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}