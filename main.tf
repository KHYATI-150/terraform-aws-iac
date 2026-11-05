############################################
# TERRAFORM CONFIGURATION
############################################

terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "terraform-remote-state-khyati"
    key            = "terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

############################################
# AWS PROVIDER
############################################

provider "aws" {
  region = "ap-southeast-2"
}

############################################
# ROOT VARIABLES
############################################

variable "admin_cidr" {
  description = "Your public IP address with /32"
  type        = string
}

variable "db_password" {
  description = "Master password for MySQL RDS"
  type        = string
  sensitive   = true
}

############################################
# DATA SOURCES
############################################

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

############################################
# NETWORK MODULE
############################################

module "network" {
  source = "./modules/network"

  vpc_cidr = "10.0.0.0/16"

  public_subnet_1_cidr = "10.0.1.0/24"
  public_subnet_2_cidr = "10.0.2.0/24"

  private_subnet_1_cidr = "10.0.11.0/24"
  private_subnet_2_cidr = "10.0.12.0/24"

  az_1 = "ap-southeast-2a"
  az_2 = "ap-southeast-2b"
}

############################################
# COMPUTE MODULE
############################################

module "compute" {
  source = "./modules/compute"

  vpc_id     = module.network.vpc_id
  subnet_id  = module.network.public_subnet_ids[0]
  ami_id     = data.aws_ami.amazon_linux.id
  admin_cidr = var.admin_cidr
}

############################################
# DATABASE MODULE
############################################

module "database" {
  source = "./modules/database"

  vpc_id                = module.network.vpc_id
  web_security_group_id = module.compute.web_security_group_id

  subnet_ids = module.network.private_subnet_ids

  db_name     = "appdb"
  db_username = "dbadmin"
  db_password = var.db_password
}

############################################
# ROOT OUTPUTS
############################################

output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "ec2_public_ip" {
  description = "EC2 public IP address"
  value       = module.compute.ec2_public_ip
}

output "website_url" {
  description = "Website URL"
  value       = "http://${module.compute.ec2_public_ip}"
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = module.database.db_endpoint
}