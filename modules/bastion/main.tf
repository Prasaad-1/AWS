# =============================================================================
# BASTION MODULE
# Public subnet — minimal attack surface
# IMDSv2 enforced
# No application — SSH jump host only
# In production: replace with AWS Systems Manager Session Manager entirely
# =============================================================================

resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.sg_id]
  iam_instance_profile        = var.iam_instance_profile
  key_name                    = var.key_name
  associate_public_ip_address = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Bastion hardening
    yum update -y
    # Disable unused services
    systemctl disable postfix 2>/dev/null || true
    # SSH hardening
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd
  EOF
  )

  tags = { Name = "${var.project}-${var.environment}-bastion" }
}
