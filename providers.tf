terraform {
  required_version = "> 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.20.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"

    }
  }
  backend "s3" {
    bucket = "terraform-tfstate-axd3"
    key    = "novatech/novatech.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Terraform = "Yes"
    }
  }
}
