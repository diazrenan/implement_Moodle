# =============================================================================
# modules/networking/main.tf
# Provisiona: VPC, subnets, IGW, Route Table, SG EC2, SG RDS
# Ref: Requisitos 3.6, 5.4
# =============================================================================

# TODO: Revise os CIDRs e AZs nas variaveis antes do terraform apply

# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# --- Subnet publica (EC2) ---
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-subnet-public"
  }
}

# --- Subnet privada A (RDS ativo — us-east-1a) ---
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_a
  availability_zone = var.availability_zone_a

  tags = {
    Name = "${var.project_name}-subnet-private-a"
  }
}

# --- Subnet privada B (exigida pelo aws_db_subnet_group — us-east-1b) ---
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_b
  availability_zone = var.availability_zone_b

  tags = {
    Name = "${var.project_name}-subnet-private-b"
  }
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# --- Route Table publica ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-rt-public"
  }
}

# --- Associacao: Route Table <-> Subnet publica ---
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --- Security Group: EC2 ---
# Ingresso: TCP 80 (HTTP) de qualquer origem; TCP 22 (SSH) do CIDR configurado
# Egresso: irrestrito
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-sg-ec2"
  description = "Security Group da instancia EC2 Moodle"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP publico"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH restrito"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  egress {
    description = "Egresso irrestrito"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-ec2"
  }
}

# --- Security Group: RDS ---
# Ingresso: TCP 5432 SOMENTE do SG da EC2 (nunca via cidr_blocks)
# Ref: Requisito 3.6, 5.4 — uso de security_groups e nao cidr_blocks
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-sg-rds"
  description = "Security Group do RDS PostgreSQL — acesso restrito ao SG da EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL somente da EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    description = "Egresso irrestrito"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-rds"
  }
}