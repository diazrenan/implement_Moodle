# =============================================================================
# modules/database/variables.tf
# Ref: Requisitos 3.12, 5.6, 5.7
# =============================================================================

# TODO: db_username e db_password sao sensitive — fornecer via TF_VAR_* ou tfvars

variable "project_name" {
  type        = string
  description = "Nome do projeto — usado como prefixo no identifier do RDS"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Lista com os IDs das subnets privadas (minimo 2 AZs) para o subnet group do RDS"
}

variable "rds_security_group_id" {
  type        = string
  description = "ID do Security Group do RDS (apenas aceita conexoes do SG da EC2)"
}

variable "db_name" {
  type        = string
  default     = "moodle"
  description = "Nome do banco de dados PostgreSQL"
}

variable "db_username" {
  type        = string
  sensitive   = true
  description = "Usuario master do banco de dados RDS PostgreSQL"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Senha master do banco de dados RDS PostgreSQL"
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "Classe da instancia RDS"
}

variable "db_allocated_storage" {
  type        = number
  default     = 20
  description = "Armazenamento alocado em GB para a instancia RDS"
}