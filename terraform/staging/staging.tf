terraform {
  backend "s3" {
    key = "terraform_state"
    region = "us-east-1"
    profile = "rap-assist-staging"
  }
}

# Specify the provider and access details
provider "aws" {
  region = "us-west-1"
  profile = "rap-assist-staging"
}

module "main" {
  source = "../main"

  rds_username = "${var.rds_username}"
  environment = "staging"
  rails_secret_key_base = "${var.rails_secret_key_base}"
}

