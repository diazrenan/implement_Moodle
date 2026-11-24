# =============================================================================
# modules/networking/outputs.tf
# Ref: Requisito 3.6
# =============================================================================

# TODO: Estes outputs sao consumidos pelos modulos compute e database

output "vpc_id" {
  description = "ID da VPC provisionada"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID da subnet publica (onde a EC2 sera provisionada)"
  value       = aws_subnet.public.id
}

output "private_subnet_ids" {
  description = "Lista com os IDs das duas subnets privadas (exigido pelo aws_db_subnet_group)"
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "ec2_security_group_id" {
  description = "ID do Security Group da instancia EC2"
  value       = aws_security_group.ec2.id
}

output "rds_security_group_id" {
  description = "ID do Security Group da instancia RDS"
  value       = aws_security_group.rds.id
}