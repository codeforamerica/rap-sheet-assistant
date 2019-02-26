resource "aws_vpc" "rap-sheet-assistant-vpc" {
  tags = {
    Name = "Rap Sheet Assistant VPC"
  }
  cidr_block = "10.0.0.0/16"
}
