
variable "vpc_id" {
  description = "VPC ID for compute resources"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "Amazon Machine Image ID"
  type        = string
}

variable "admin_cidr" {
  description = "Allowed admin IP address"
  type        = string
}