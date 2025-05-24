resource "aws_s3_bucket" "crm_data" {
  bucket = "${var.project_name}-data-bucket"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "CRM Data Bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "crm_data_versioning" {
  bucket = aws_s3_bucket.crm_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "crm_data_sse" {
  bucket = aws_s3_bucket.crm_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
