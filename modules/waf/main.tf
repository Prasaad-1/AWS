# =============================================================================
# WAF MODULE
# AWS Managed Rule Groups:
#   - AWSManagedRulesCommonRuleSet      (OWASP Top 10)
#   - AWSManagedRulesKnownBadInputsRuleSet
#   - AWSManagedRulesSQLiRuleSet
#   - AWSManagedRulesAmazonIpReputationList
# Custom Rules:
#   - Rate limiting (2000 req/5min per IP)
#   - IP block list (manual deny list)
# Logging to CloudWatch
# =============================================================================

resource "aws_wafv2_ip_set" "blocked" {
  name               = "${var.project}-${var.environment}-blocked-ips"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.blocked_ip_list
}

resource "aws_wafv2_web_acl" "main" {
  name  = "${var.project}-${var.environment}-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # Rule 1: Block listed IPs
  rule {
    name     = "BlockListedIPs"
    priority = 1
    action { block {} }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blocked.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockListedIPs"
      sampled_requests_enabled   = true
    }
  }

  # Rule 2: Rate limiting
  rule {
    name     = "RateLimit"
    priority = 2
    action { block {} }
    statement {
      rate_based_statement {
        limit              = var.rate_limit
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimit"
      sampled_requests_enabled   = true
    }
  }

  # Rule 3: AWS Common Rule Set (OWASP Top 10)
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 3
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Rule 4: Known Bad Inputs
  rule {
    name     = "AWSManagedRulesKnownBadInputs"
    priority = 4
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputs"
      sampled_requests_enabled   = true
    }
  }

  # Rule 5: SQLi
  rule {
    name     = "AWSManagedRulesSQLi"
    priority = 5
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Rule 6: IP Reputation List
  rule {
    name     = "AWSManagedRulesIPReputation"
    priority = 6
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IPReputationList"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project}-${var.environment}-waf"
    sampled_requests_enabled   = true
  }

  tags = { Name = "${var.project}-${var.environment}-waf" }
}

# Associate WAF with ALB
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

# WAF Logging to CloudWatch
resource "aws_cloudwatch_log_group" "waf" {
  name              = "aws-waf-logs-${var.project}-${var.environment}"
  retention_in_days = 30
}

resource "aws_wafv2_web_acl_logging_configuration" "main" {
  log_destination_configs = [aws_cloudwatch_log_group.waf.arn]
  resource_arn            = aws_wafv2_web_acl.main.arn
}
