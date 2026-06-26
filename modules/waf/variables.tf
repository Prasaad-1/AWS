variable "project"           { type = string }
variable "environment"       { type = string }
variable "alb_arn"           { type = string }
variable "rate_limit"        { type = number; default = 2000 }
variable "blocked_ip_list"   { type = list(string); default = [] }
