resource "aws_vpc" "rap-sheet-assistant-vpc" {
  tags = {
    Name = "Rap Sheet Assistant VPC"
  }
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "rap-sheet-assistant-public" {
  vpc_id     = "${aws_vpc.rap-sheet-assistant-vpc.id}"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public Subnet (Rap Sheet Assistant)"
  }
}

resource "aws_subnet" "rap-sheet-assistant-private-1" {
  vpc_id     = "${aws_vpc.rap-sheet-assistant-vpc.id}"
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Private Subnet 1 (Rap Sheet Assistant)"
  }
}

resource "aws_subnet" "rap-sheet-assistant-private-2" {
  vpc_id     = "${aws_vpc.rap-sheet-assistant-vpc.id}"
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "Private Subnet 2 (Rap Sheet Assistant)"
  }
}
