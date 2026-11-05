############################################
# RDS SUBNET GROUP
############################################

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "khyati-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "khyati-db-subnet-group"
  }
}

############################################
# RDS SECURITY GROUP
############################################

resource "aws_security_group" "db_sg" {
  name        = "khyati-rds-security-group"
  description = "Allow MySQL only from EC2"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from web server"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.web_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "khyati-rds-sg"
  }
}

############################################
# RDS MYSQL DATABASE
############################################

resource "aws_db_instance" "db" {
  identifier        = "khyati-terraform-mysql"
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period    = 1
  auto_minor_version_upgrade = true

  deletion_protection = false
  skip_final_snapshot = true

  tags = {
    Name        = "khyati-terraform-rds"
    Environment = "Dev"
  }
}