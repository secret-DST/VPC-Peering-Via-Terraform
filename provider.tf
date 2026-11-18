terraform {
  required_version = "~> 1.15.0"

  required_providers {
    aws = {
      version = "~> 6.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.primary_region
  alias  = "primary"
}


provider "aws" {
  region = var.secondary_region
  alias  = "secondary"
}