# =============================================================================
# modules/database/main.tf
# Provisiona: aws_db_subnet_group + aws_db_instance (PostgreSQL 15)
# Ref: Requisitos 3.12, 5.6
# =============================================================================

# TODO: Revise db_instance_class e db_allocated_storage antes do terraform apply
# O RDS pode levar 5-10 minutos para ficar disponivel apos o terraform apply

resource "aws_db_subnet_group" "moodle" {
  name        = "${var.project_name}-db-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "Subnet group do RDS Moodle — cobre us-east-1a e us-east-1b"

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "moodle" {
  identifier             = "${var.project_name}-db"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  storage_type           = "gp2"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.moodle.name
  vpc_security_group_ids = [var.rds_security_group_id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false

  tags = {
    Name = "${var.project_name}-rds"
  }
}