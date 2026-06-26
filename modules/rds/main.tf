# =============================================================================
# RDS MODULE — PostgreSQL Multi-AZ
# Subnet group spans private DB subnets in both AZs
# Encrypted at rest with AWS managed KMS key
# Deletion protection OFF (lab) — flip to true in production
# Snapshot-restore workflow supported via snapshot_identifier variable
# Performance Insights enabled for query analysis
# =============================================================================

resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_db_subnet_ids
  tags       = { Name = "${var.project}-${var.environment}-db-subnet-group" }
}

resource "aws_db_parameter_group" "postgres" {
  name   = "${var.project}-${var.environment}-pg-params"
  family = "postgres15"

  # Security hardening parameters
  parameter {
    name  = "log_connections"
    value = "1"
  }
  parameter {
    name  = "log_disconnections"
    value = "1"
  }
  parameter {
    name  = "log_checkpoints"
    value = "1"
  }
  parameter {
    name  = "log_lock_waits"
    value = "1"
  }

  tags = { Name = "${var.project}-${var.environment}-pg-params" }
}

resource "aws_db_instance" "main" {
  identifier     = "${var.project}-${var.environment}-rds"
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = 100 # Auto-scaling storage cap
  storage_type          = "gp3"
  storage_encrypted     = true # Encryption at rest

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_sg_id]
  parameter_group_name   = aws_db_parameter_group.postgres.name

  multi_az               = var.multi_az
  publicly_accessible    = false # Never expose RDS publicly
  deletion_protection    = false # Lab only — set true in production

  backup_retention_period = 7    # 7 days PITR
  backup_window           = "02:00-03:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project}-${var.environment}-final-snapshot"

  # Restore from snapshot if provided (snapshot-restore workflow)
  snapshot_identifier = var.snapshot_identifier

  # Performance Insights for query analysis
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  # Enhanced monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true

  tags = { Name = "${var.project}-${var.environment}-rds" }
}

# IAM role for Enhanced Monitoring
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.project}-${var.environment}-rds-monitoring-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
