variable "rds_username" {}

variable "aws_az1" {
  description = "AWS availability zone 1"
  default = "us-west-1a"
}

variable "aws_az2" {
  description = "AWS availability zone 1"
  default = "us-west-1c"
}

variable "environment" {
  description = "staging or prod?"
}

variable "rails_secret_key_base" {
  description = "secret key used to sign cookies and other things"
}
