# main.tf

terraform {
    backend "s3" {
        bucket      = "crm-platform-data-bucket"
        key         = "terraform/state/terraform.tfstate"
        region      = "us-east-1"
        encrypt     = true
    }
    
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }

    required_version = ">= 1.3.0"
}

provider "aws" {
    region = var.aws_region
}