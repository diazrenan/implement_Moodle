# =============================================================================
# main.tf — Orquestracao dos modulos Terraform
# Instancia os modulos networking, database e compute na ordem correta.
# Ref: Requisitos 3.1, 3.4
# =============================================================================

# TODO: Revise as variaveis passadas aos modulos antes do terraform apply.
# Configure project_name, db_username, db_password, ec2_public_key e
# moodle_admin_password via terraform.tfvars ou variaveis TF_VAR_*.

# -----------------------------------------------------------------------------
# Modulo networking — VPC, subnets, IGW, Route Table, SG EC2, SG RDS
# -----------------------------------------------------------------------------
module "networking" {
  source = "./modules/networking"

  project_name     = var.project_name
  ssh_allowed_cidr = var.ssh_allowed_cidr
}

# -----------------------------------------------------------------------------
# Modulo database — RDS PostgreSQL 15 e subnet group
# Depende de: networking (private_subnet_ids, rds_security_group_id)
# -----------------------------------------------------------------------------
module "database" {
  source = "./modules/database"

  project_name          = var.project_name
  private_subnet_ids    = module.networking.private_subnet_ids
  rds_security_group_id = module.networking.rds_security_group_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
}

# -----------------------------------------------------------------------------
# Modulo compute — EC2 t3.medium com Amazon Linux 2023 e user_data.sh
# Depende de: networking (public_subnet_id, ec2_security_group_id)
#             database  (rds_endpoint, rds_port)
# -----------------------------------------------------------------------------
module "compute" {
  source = "./modules/compute"

  project_name          = var.project_name
  public_subnet_id      = module.networking.public_subnet_id
  ec2_security_group_id = module.networking.ec2_security_group_id
  ec2_public_key        = var.ec2_public_key
  ec2_instance_type     = var.ec2_instance_type
  rds_endpoint          = module.database.rds_endpoint
  rds_port              = module.database.rds_port
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  moodle_admin_user     = var.moodle_admin_user
  moodle_admin_password = var.moodle_admin_password
  moodle_site_name      = var.moodle_site_name
}