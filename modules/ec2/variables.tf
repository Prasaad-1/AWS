variable "project"               { type = string }
variable "environment"           { type = string }
variable "ami_id"                { type = string }
variable "instance_type"         { type = string; default = "t3.micro" }
variable "subnet_id"             { type = string }
variable "sg_id"                 { type = string }
variable "iam_instance_profile"  { type = string }
variable "key_name"              { type = string }
variable "db_host"               { type = string; default = "" }
variable "db_name"               { type = string; default = "" }
variable "db_secret_arn"         { type = string; default = "" }
