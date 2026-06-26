# =============================================================================
# IAM MODULE
# Principle of least privilege throughout
# Web EC2 role: SSM access + CloudWatch logs + Secrets Manager read
# Bastion role: SSM access only
# No wildcard (*) actions on sensitive services
# =============================================================================

# --- Web EC2 IAM Role ---
resource "aws_iam_role" "web_ec2" {
  name = "${var.project}-${var.environment}-web-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# SSM Session Manager (replaces direct SSH in production)
resource "aws_iam_role_policy_attachment" "web_ssm" {
  role       = aws_iam_role.web_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# CloudWatch logs for application logging
resource "aws_iam_role_policy_attachment" "web_cw" {
  role       = aws_iam_role.web_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Secrets Manager — read DB credentials only
resource "aws_iam_role_policy" "web_secrets" {
  name = "read-db-secret"
  role = aws_iam_role.web_ec2.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = "arn:aws:secretsmanager:ap-south-1:*:secret:${var.project}/${var.environment}/db*"
    }]
  })
}

resource "aws_iam_instance_profile" "web_ec2" {
  name = "${var.project}-${var.environment}-web-ec2-profile"
  role = aws_iam_role.web_ec2.name
}

# --- Bastion IAM Role ---
resource "aws_iam_role" "bastion" {
  name = "${var.project}-${var.environment}-bastion-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.project}-${var.environment}-bastion-profile"
  role = aws_iam_role.bastion.name
}
