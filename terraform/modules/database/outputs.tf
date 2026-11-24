# =============================================================================
# modules/database/outputs.tf
# Ref: Requisito 3.12
# =============================================================================

# TODO: rds_endpoint e rds_port sao consumidos pelo modulo compute via main.tf raiz

output "rds_endpoint" {
  description = "Endereco do RDS PostgreSQL (somente host, sem porta) — usado no MOODLE_DATABASE_HOST"
  value       = aws_db_instance.moodle.address
}

output "rds_port" {
  description = "Porta do RDS PostgreSQL — usado no MOODLE_DATABASE_PORT_NUMBER"
  value       = tostring(aws_db_instance.moodle.port)
}