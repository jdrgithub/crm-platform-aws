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

resource "aws_s3_bucket" "frontend" {
  bucket = "${var.project_name}-frontend-bucket"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Frontend Bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls         = false
  block_public_policy       = false 
  ignore_public_acls        = false 
  restrict_public_buckets   = false 
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = ["s3:GetObject"],
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
}