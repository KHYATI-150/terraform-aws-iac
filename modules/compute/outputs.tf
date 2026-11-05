############################################
# COMPUTE MODULE OUTPUTS
############################################

output "ec2_public_ip" {
  description = "Public IP address of EC2 instance"
  value       = aws_instance.web.public_ip
}

output "web_security_group_id" {
  description = "EC2 web security group ID"
  value       = aws_security_group.web_sg.id
}