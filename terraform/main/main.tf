# Start with a VPC

resource "aws_vpc" "rap-sheet-assistant-vpc" {
  tags = {
    Name = "Rap Sheet Assistant VPC"
  }
  cidr_block = "10.0.0.0/16"
}

# Create subnets

resource "aws_subnet" "rap-sheet-assistant-public-1" {
  vpc_id     = "${aws_vpc.rap-sheet-assistant-vpc.id}"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public Subnet 1 (Rap Sheet Assistant)"
  }
}

resource "aws_subnet" "rap-sheet-assistant-public-2" {
  vpc_id     = "${aws_vpc.rap-sheet-assistant-vpc.id}"
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Public Subnet 2 (Rap Sheet Assistant)"
  }
}

resource "aws_subnet" "rap-sheet-assistant-private-1" {
  vpc_id     = "${aws_vpc.rap-sheet-assistant-vpc.id}"
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "Private Subnet 1 (Rap Sheet Assistant)"
  }
}

resource "aws_subnet" "rap-sheet-assistant-private-2" {
  vpc_id     = "${aws_vpc.rap-sheet-assistant-vpc.id}"
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "Private Subnet 2 (Rap Sheet Assistant)"
  }
}

# Give all subnets internet access with default route

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.rap-sheet-assistant-vpc.id}"

  tags = {
    Name = "Rap Sheet Assistant main gateway"
  }
}

resource "aws_route_table" "internet_access" {
  vpc_id = "${aws_vpc.rap-sheet-assistant-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags = {
    Name = "Rap Sheet Assistant route to main gateway"
  }
}

resource "aws_route_table_association" "public_internet_access_1" {
  subnet_id = "${aws_subnet.rap-sheet-assistant-public-1.id}"
  route_table_id = "${aws_route_table.internet_access.id}"
}

resource "aws_route_table_association" "public_internet_access_2" {
  subnet_id = "${aws_subnet.rap-sheet-assistant-public-2.id}"
  route_table_id = "${aws_route_table.internet_access.id}"
}

# Place NAT gateways in public subnets

resource "aws_eip" "public-nat-eip-1" {
  vpc = true
  depends_on = [
    "aws_internet_gateway.default"
  ]

  tags = {
    Name = "Rap Sheet Assistant public 1"
  }
}

resource "aws_eip" "public-nat-eip-2" {
  vpc = true
  depends_on = [
    "aws_internet_gateway.default"
  ]

  tags = {
    Name = "Rap Sheet Assistant public 1"
  }
}

resource "aws_nat_gateway" "public-gw-1" {
  allocation_id = "${aws_eip.public-nat-eip-1.id}"
  subnet_id = "${aws_subnet.rap-sheet-assistant-public-1.id}"

  depends_on = [
    "aws_internet_gateway.default"
  ]

  tags {
    Name = "NAT"
  }
}

resource "aws_nat_gateway" "public-gw-2" {
  allocation_id = "${aws_eip.public-nat-eip-2.id}"
  subnet_id = "${aws_subnet.rap-sheet-assistant-public-2.id}"

  depends_on = [
    "aws_internet_gateway.default"
  ]

  tags {
    Name = "NAT"
  }
}

# Route private traffic VIA NAT gateways

resource "aws_route_table" "private_internet_access" {
  vpc_id = "${aws_vpc.rap-sheet-assistant-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.public-gw-1.id}"
  }
}

resource "aws_route_table_association" "private_internet_access_1" {
  subnet_id = "${aws_subnet.rap-sheet-assistant-private-1.id}"
  route_table_id = "${aws_route_table.private_internet_access.id}"
}

resource "aws_route_table_association" "private_internet_access_2" {
  subnet_id = "${aws_subnet.rap-sheet-assistant-private-2.id}"
  route_table_id = "${aws_route_table.private_internet_access.id}"
}
