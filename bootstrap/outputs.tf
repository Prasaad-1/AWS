output "tfstate_bucket_name" {
  description = "S3 bucket name for Terraform state — paste into backend.tf"
  value       = aws_s3_bucket.tfstate.bucket
}

output "tfstate_lock_table" {
  description = "DynamoDB lock table name — paste into backend.tf"
  value       = aws_dynamodb_table.tfstate_lock.name
}

output "aws_region" {
  value = var.aws_region
}
