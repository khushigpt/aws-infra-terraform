terraform {
    required_version = ">= 1.0"
    
    required_providers {
	aws = {
	  source = "hashicorp/aws"
	  version = "~>5.0"
	}
    }
    
    backend "s3" {
	bucket  =  "khushi-terraform-state-2026"
	key     =  "aws-infra/terraform.tfstate"
	region  =  "ap-south-1"
	encrypt =  true
    }
}
provider "aws" {
    region = var.aws_region
}
