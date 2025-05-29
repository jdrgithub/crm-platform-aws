variable "aws_region" {
    description = "AWS region to deploy to"
    type        = string
    default     = "us-east-1"
}

variable "project_name" {
    description = "Project prefix for resource names"
    type        = string
    default     = "crm-platform"
}

variable "environment" {
    description = "Deployment environment"
    type        = string
    default     = "dev"
}

variable "frontend_origin" {
  type        = string
  description = "Allowed origin for CORS"
}