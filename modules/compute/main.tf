
############################################
# EC2 SECURITY GROUP
############################################

resource "aws_security_group" "web_sg" {
  name        = "khyati-web-security-group"
  description = "Allow HTTP and restricted SSH"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from administrator"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "khyati-web-sg"
  }
}

############################################
# EC2 INSTANCE
############################################

resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y httpd

    systemctl enable httpd
    systemctl start httpd

    cat > /var/www/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Khyati | AWS Terraform Project</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          background: linear-gradient(135deg, #0f2027, #203a43, #2c5364);
          color: white;
          text-align: center;
          padding: 100px 20px;
        }
        .container {
          max-width: 850px;
          margin: auto;
          padding: 40px;
          background: rgba(0,0,0,0.4);
          border-radius: 15px;
        }
        h1 { font-size: 36px; }
        .badge {
          display: inline-block;
          padding: 12px 22px;
          background: #22c55e;
          color: #022c22;
          border-radius: 25px;
          font-weight: bold;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>Terraform Infrastructure Deployed!</h1>
        <h2>AWS VPC | EC2 | RDS | S3 Remote State</h2>
        <p class="badge">Infrastructure as Code</p>
        <p>Deployed using Terraform on AWS Sydney Region.</p>
        <p>Built by Khyati | AWS DevOps Portfolio Project</p>
      </div>
    </body>
    </html>
    HTML
  EOF

  tags = {
    Name        = "khyati-terraform-web-instance"
    Environment = "Dev"
  }
}
