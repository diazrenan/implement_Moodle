# =============================================================================
# modules/compute/main.tf
# Provisiona: data LabRole, data AMI, aws_key_pair, aws_instance
# Ref: Requisitos 3.7, 4.2, 4.3
# PROIBIDO: nenhum resource aws_iam_role, aws_iam_instance_profile,
#           aws_iam_user, aws_route53_*, aws_acm_*, aws_cloudfront_*
# =============================================================================

# TODO: Revise ec2_instance_type e ec2_public_key antes do terraform apply
# O build Docker na EC2 leva 10-20 min — monitore via:
#   ssh ec2-user@<DNS> -i ~/.ssh/<chave> "sudo tail -f /var/log/user-data-moodle.log"

# --- IAM Instance Profile do Learn Lab (somente via data source — nunca resource) ---
data "aws_iam_instance_profile" "lab_role" {
  name = "LabInstanceProfile"
}

# --- AMI mais recente do Amazon Linux 2023 ---
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# --- Par de chaves SSH ---
resource "aws_key_pair" "moodle" {
  key_name   = "${var.project_name}-key"
  public_key = var.ec2_public_key

  tags = {
    Name = "${var.project_name}-key"
  }
}

# --- Instancia EC2 com Moodle via user_data ---
resource "aws_instance" "moodle" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.ec2_instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.ec2_security_group_id]
  key_name               = aws_key_pair.moodle.key_name
  iam_instance_profile   = data.aws_iam_instance_profile.lab_role.name

  user_data = templatefile("${path.module}/user_data.sh", {
    rds_endpoint          = var.rds_endpoint
    rds_port              = var.rds_port
    db_name               = var.db_name
    db_username           = var.db_username
    db_password           = var.db_password
    moodle_admin_user     = var.moodle_admin_user
    moodle_admin_password = var.moodle_admin_password
    moodle_site_name      = var.moodle_site_name
  })

  tags = {
    Name = "${var.project_name}-ec2"
  }
}