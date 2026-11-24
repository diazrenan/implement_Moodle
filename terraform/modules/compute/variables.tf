# =============================================================================
# modules/compute/variables.tf
# Ref: Requisitos 3.7, 5.7
# =============================================================================

# TODO: ec2_public_key, db_username, db_password e moodle_admin_password
# sao sensitive — fornecer via TF_VAR_* ou terraform.tfvars (nunca em texto claro)

variable "project_name" {
  type        = string
  description = "Nome do projeto — usado como prefixo nos recursos EC2"
}

variable "public_subnet_id" {
  type        = string
  description = "ID da subnet publica onde a instancia EC2 sera provisionada"
}

variable "ec2_security_group_id" {
  type        = string
  description = "ID do Security Group da EC2 (HTTP 80, SSH 22)"
}

variable "ec2_instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Tipo da instancia EC2"
}

variable "ec2_public_key" {
  type        = string
  sensitive   = true
  description = "Chave publica SSH no formato OpenSSH (saida de: cat ~/.ssh/id_rsa.pub)"
}

variable "rds_endpoint" {
  type        = string
  description = "Endereco do endpoint RDS PostgreSQL (sem porta) — injetado no user_data.sh"
}

variable "rds_port" {
  type        = string
  default     = "5432"
  description = "Porta do RDS PostgreSQL"
}

variable "db_name" {
  type        = string
  default     = "moodle"
  description = "Nome do banco de dados PostgreSQL"
}

variable "db_username" {
  type        = string
  sensitive   = true
  description = "Usuario master do banco de dados RDS"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Senha master do banco de dados RDS"
}

variable "moodle_admin_user" {
  type        = string
  default     = "admin"
  description = "Nome de usuario do administrador do Moodle"
}

variable "moodle_admin_password" {
  type        = string
  sensitive   = true
  description = "Senha do administrador do Moodle"
}

variable "moodle_site_name" {
  type        = string
  default     = "Moodle Challenge"
  description = "Nome exibido no site Moodle"
}