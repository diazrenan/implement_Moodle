# =============================================================================
# variables.tf — Variáveis raiz do Terraform
# Ref: Requisitos 3.14, 5.5, 5.7
# =============================================================================

# TODO: Preencha as variáveis sem default via terraform.tfvars ou TF_VAR_* secrets
# no GitHub Actions (ver .github/workflows/terraform-plan.yml)

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Região AWS onde os recursos serão provisionados (AWS Learn Lab: us-east-1)"
}

variable "project_name" {
  type        = string
  description = "Nome do projeto — usado como prefixo nos nomes de todos os recursos AWS"
}

variable "ec2_instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Tipo da instância EC2 para o servidor Moodle"
}

variable "ec2_public_key" {
  type        = string
  sensitive   = true
  description = "Chave pública SSH no formato OpenSSH (saída de: cat ~/.ssh/id_rsa.pub) para acesso à instância EC2"
}

variable "ssh_allowed_cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = "CIDR autorizado para acesso SSH (porta 22) à EC2. AVISO DE SEGURANÇA: substitua 0.0.0.0/0 pelo seu próprio endereço IP no formato x.x.x.x/32 para evitar exposição pública da porta SSH."
}

variable "db_name" {
  type        = string
  default     = "moodle"
  description = "Nome do banco de dados PostgreSQL no RDS"
}

variable "db_username" {
  type        = string
  sensitive   = true
  description = "Usuário master do banco de dados RDS PostgreSQL"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Senha master do banco de dados RDS PostgreSQL (mínimo 8 caracteres)"
}

variable "moodle_admin_user" {
  type        = string
  default     = "admin"
  description = "Nome de usuário do administrador do Moodle"
}

variable "moodle_admin_password" {
  type        = string
  sensitive   = true
  description = "Senha do administrador do Moodle (mínimo 8 caracteres, deve conter letras e números)"
}

variable "moodle_site_name" {
  type        = string
  default     = "Moodle Challenge"
  description = "Nome exibido no site Moodle"
}