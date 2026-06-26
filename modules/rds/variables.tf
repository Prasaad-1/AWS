variable "project"              { type = string }
variable "environment"          { type = string }
variable "private_db_subnet_ids" { type = list(string) }
variable "rds_sg_id"            { type = string }
variable "db_name"              { type = string; default = "kratvalab" }
variable "db_username"          { type = string; default = "dbadmin" }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "instance_class"       { type = string; default = "db.t3.micro" }
variable "allocated_storage"    { type = number; default = 20 }
variable "multi_az" {
  description = "Multi-AZ for HA — set false to save cost when lab is idle"
  type        = bool
  default     = true
}
variable "skip_final_snapshot" {
  description = "Set true for lab (fast destroy), false for production"
  type        = bool
  default     = false
}
variable "snapshot_identifier" {
  description = "Restore from snapshot — used for snapshot-restore workflow"
  type        = string
  default     = null
}
