# =============================================================================
# modules/compute/outputs.tf
# Ref: Requisito 3.7
# =============================================================================

# TODO: ec2_public_dns e usado no output raiz e no health-check.sh apos o apply

output "ec2_public_dns" {
  description = "DNS publico da instancia EC2 — acesse o Moodle via http://<este_valor>"
  value       = aws_instance.moodle.public_dns
}

output "ec2_instance_id" {
  description = "ID da instancia EC2"
  value       = aws_instance.moodle.id
}