terraform {
 required_version = ">= 1.6.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.71.0"
    }
  }
  backend "s3" {
    
  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "delegated_admin"
  region = var.region  # Change to your desired region
  assume_role {
    role_arn = "arn:aws:iam::881490103380:role/OrganizationAccountAccessRole"  # Replace with the ARN of your assume role
  }
}


