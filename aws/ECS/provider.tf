provider "aws" {
  #profile = "flow"
  region  = var.region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.59.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }
  }
}
