# =============================================================================
# SECURITY GROUPS MODULE
# Principle: least privilege — every rule explicitly justified in comments
# ALB SG   → accepts 443 from internet (80 redirect only)
# Web EC2  → accepts 80/443 from ALB SG only
# Bastion  → accepts 22 from your IP only
# RDS      → accepts 5432 from Web EC2 SG only
# =============================================================================

# --- ALB Security Group ---
resource "aws_security_group" "alb" {
  name        = "${var.project}-${var.environment}-sg-alb"
  description = "ALB: allow HTTPS from internet, HTTP for redirect only"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP redirect to HTTPS"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Forward to web EC2 only"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = { Name = "${var.project}-${var.environment}-sg-alb" }
}

# --- Web EC2 Security Group ---
resource "aws_security_group" "web" {
  name        = "${var.project}-${var.environment}-sg-web"
  description = "Web EC2: ingress only from ALB SG"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "SSH from bastion only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    description = "Outbound for package installs via NAT"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project}-${var.environment}-sg-web" }
}

# --- Bastion Security Group ---
resource "aws_security_group" "bastion" {
  name        = "${var.project}-${var.environment}-sg-bastion"
  description = "Bastion: SSH from operator IP only — never 0.0.0.0/0"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from operator IP only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    description = "SSH to private subnets"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = { Name = "${var.project}-${var.environment}-sg-bastion" }
}

# --- RDS Security Group ---
resource "aws_security_group" "rds" {
  name        = "${var.project}-${var.environment}-sg-rds"
  description = "RDS: PostgreSQL from web EC2 SG only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from web EC2 only"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  # No egress rule — RDS initiates no outbound connections

  tags = { Name = "${var.project}-${var.environment}-sg-rds" }
}
