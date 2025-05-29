# print the Lambda URL

output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.crm_api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}/contacts"
}

output "frontend_bucket" {
  value = aws_s3_bucket.frontend.id
}

output "frontend_bucket_url" {
  value = "https://${aws_s3_bucket.frontend.bucket}.s3.amazonaws.com"
  description = "Public URL of the frontend S3 bucket"
}
