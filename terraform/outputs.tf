# =============================================================================
# outputs.tf — Outputs raiz do Terraform
# Ref: Requisito 3.13
# =============================================================================

# TODO: Apos o terraform apply, consulte com: terraform output

output "ec2_public_dns" {
  description = "DNS publico da instancia EC2 — acesse o Moodle via http://<este_valor>"
  value       = module.compute.ec2_public_dns
}

output "rds_endpoint" {
  description = "Endereco do endpoint RDS PostgreSQL (sem porta)"
  value       = module.database.rds_endpoint
}

output "vpc_id" {
  description = "ID da VPC provisionada"
  value       = module.networking.vpc_id
}