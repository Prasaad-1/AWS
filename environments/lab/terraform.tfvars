# =============================================================================
# LAB VARIABLES — Edit before apply
# =============================================================================
project     = "kratva-security-lab"
environment = "lab"
aws_region  = "ap-south-1"

vpc_cidr = "10.0.0.0/16"
azs      = ["ap-south-1a", "ap-south-1b"]

public_subnet_cidrs      = ["10.0.1.0/24", "10.0.2.0/24"]
private_app_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
private_db_subnet_cidrs  = ["10.0.20.0/24", "10.0.21.0/24"]

# CHANGE THESE before apply:
my_ip_cidr      = "YOUR_IP/32"           # curl ifconfig.me
key_name        = "your-key-pair-name"
ami_id          = "ami-0f58b397bc5c1f2e8" # Amazon Linux 2 ap-south-1 — verify latest
certificate_arn = "arn:aws:acm:ap-south-1:ACCOUNT_ID:certificate/CERT_ID"

# Cost control toggles:
enable_nat_gateway  = true   # Set false to destroy NAT GW instantly
rds_multi_az        = true   # Set false to halve RDS cost when idle
skip_final_snapshot = false  # Set true only for throwaway lab runs

# db_password — set via TF_VAR_db_password environment variable, NOT here
