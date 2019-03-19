terraform {
  backend "s3" {
    key = "terraform_state"
    region = "us-east-1"
  }
}

# Specify the provider and access details
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "us-west-1"
}

module "main" {
  source = "../main"

  rds_username = "${var.rds_username}"
  environment = "staging"
  rails_secret_key_base = "${var.rails_secret_key_base}"
}

