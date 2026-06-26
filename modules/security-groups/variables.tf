variable "project"     { type = string }
variable "environment" { type = string }
variable "vpc_id"      { type = string }
variable "vpc_cidr"    { type = string }
variable "my_ip_cidr" {
  description = "Your IP in CIDR for bastion SSH access e.g. 1.2.3.4/32"
  type        = string
}
