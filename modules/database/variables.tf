############################################
# DATABASE MODULE VARIABLES
############################################

variable "vpc_id" {
  description = "VPC ID for the database security group"
  type        = string
}

variable "web_security_group_id" {
  description = "EC2 web security group ID allowed to access RDS"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for RDS"
  type        = list(string)
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database master username"
  type        = string
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}