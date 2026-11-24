# =============================================================================
# versions.tf — Configuração do provider AWS e versão mínima do Terraform
# Ref: Requisito 3.2 — provider aws ~> 5.0, required_version >= 1.5.0
# NOTA: Este arquivo é isento da exigência de comentário # TODO: por design.
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}