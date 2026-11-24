# =============================================================================
# modules/networking/variables.tf
# Ref: Requisitos 3.6, 5.5
# =============================================================================

# TODO: Ajuste os CIDRs ou AZs se necessario para o seu ambiente

variable "project_name" {
  type        = string
  description = "Nome do projeto — usado como prefixo nos nomes dos recursos de rede"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block da VPC"
}

variable "public_subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "CIDR da subnet publica (hospeda a EC2)"
}

variable "private_subnet_cidr_a" {
  type        = string
  default     = "10.0.2.0/24"
  description = "CIDR da subnet privada A em us-east-1a (hospeda RDS)"
}

variable "private_subnet_cidr_b" {
  type        = string
  default     = "10.0.3.0/24"
  description = "CIDR da subnet privada B em us-east-1b (exigida pelo subnet group do RDS)"
}

variable "availability_zone_a" {
  type        = string
  default     = "us-east-1a"
  description = "AZ primaria (subnet publica + subnet privada A)"
}

variable "availability_zone_b" {
  type        = string
  default     = "us-east-1b"
  description = "AZ secundaria (subnet privada B — exigida pelo aws_db_subnet_group)"
}

variable "ssh_allowed_cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = "CIDR autorizado para SSH (porta 22) na EC2. AVISO DE SEGURANÇA: substitua 0.0.0.0/0 pelo seu proprio IP no formato x.x.x.x/32."
}