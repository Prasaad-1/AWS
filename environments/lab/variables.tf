variable "project"     { type = string }
variable "environment" { type = string }
variable "aws_region"  { type = string }

variable "vpc_cidr"                  { type = string }
variable "azs"                       { type = list(string) }
variable "public_subnet_cidrs"       { type = list(string) }
variable "private_app_subnet_cidrs"  { type = list(string) }
variable "private_db_subnet_cidrs"   { type = list(string) }

variable "my_ip_cidr"                { type = string }
variable "key_name"                  { type = string }
variable "ami_id"                    { type = string }
variable "certificate_arn"           { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}

variable "enable_nat_gateway" { type = bool; default = true }
variable "rds_multi_az"       { type = bool; default = true }
variable "skip_final_snapshot" { type = bool; default = false }
variable "rate_limit"         { type = number; default = 2000 }
variable "blocked_ip_list"    { type = list(string); default = [] }
