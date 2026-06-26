# =============================================================================
# WEB EC2 MODULE
# Private subnet only — no public IP
# Apache bootstrapped via user_data
# IMDSv2 enforced (security hardening — blocks SSRF metadata theft)
# EBS encrypted at rest
# SSM Session Manager enabled (no direct SSH needed in practice)
# =============================================================================

resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.sg_id]
  iam_instance_profile   = var.iam_instance_profile
  key_name               = var.key_name

  # IMDSv2 enforced — critical security control
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Forces IMDSv2
    http_put_response_hop_limit = 1          # Blocks container metadata SSRF
  }

  # EBS root volume encrypted
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e
    yum update -y
    yum install -y httpd
    systemctl enable httpd
    systemctl start httpd

    # Health check endpoint for ALB
    echo "healthy" > /var/www/html/health

    # Basic index page
    echo "<h1>${var.project} - ${var.environment}</h1>" > /var/www/html/index.html

    # Install SSM agent (usually pre-installed on Amazon Linux 2)
    yum install -y amazon-ssm-agent
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
  EOF
  )

  tags = { Name = "${var.project}-${var.environment}-web-ec2" }
}
