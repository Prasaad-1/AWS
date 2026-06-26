variable "project"           { type = string }
variable "environment"       { type = string }
variable "vpc_id"            { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "alb_sg_id"         { type = string }
variable "web_ec2_id"        { type = string }
variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener"
  type        = string
}
