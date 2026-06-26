# =============================================================================
# REMOTE STATE BACKEND
# Run bootstrap/ first, then paste the outputs here
# =============================================================================
terraform {
  backend "s3" {
    bucket         = "REPLACE_WITH_BOOTSTRAP_OUTPUT_bucket_name"
    key            = "lab/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "REPLACE_WITH_BOOTSTRAP_OUTPUT_lock_table"
    encrypt        = true
  }
}
