variable "project" {
  description = "Project name used as prefix for all resources"
  type        = string
  default     = "kratva-security-lab"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "lab"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}
