############################################
# DATABASE MODULE OUTPUTS
############################################

output "db_endpoint" {
  description = "RDS MySQL database endpoint"
  value       = aws_db_instance.db.endpoint
}