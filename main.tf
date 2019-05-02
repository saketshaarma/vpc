provider "aws" {
  access_key = ""
  secret_key = ""
  region = "us-east-1"
}
resource "aws_vpc" "example_vpc" {
  cidr_block = "${var.aws_vpc_cidr}"
  enable_dns_support = true
  tags {
    Name="example_vpc"
  }
}
resource "aws_subnet" "example_subnet_public" {
  count = "${length(data.aws_availability_zones.available.names)}"
  cidr_block = "${cidrsubnet(var.aws_vpc_cidr,8 ,count.index)}"
  vpc_id = "${aws_vpc.example_vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true
  tags {
    Name="example_vpc_public_subnet"
  }
}
resource "aws_subnet" "example_subnet_private" {
  count = "${length(data.aws_availability_zones.available.names)}"
  cidr_block = "${cidrsubnet(var.aws_vpc_cidr,8 ,7+count.index)}"
  vpc_id = "${aws_vpc.example_vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = false
  tags {
    Name="example_vpc_private_subnet"
  }
}
resource "aws_internet_gateway" "example_internet_gateway" {
  vpc_id = "${aws_vpc.example_vpc.id}"
  tags {
    Name="example_internet_gateway"
  }
}

resource "aws_route_table" "example_route_table_pub" {
  vpc_id = "${aws_vpc.example_vpc.id}"
  route {
    cidr_block = "${var.public_subnet_igw}"
    gateway_id = "${aws_internet_gateway.example_internet_gateway.id}"
  }
  tags {
    Name="example_route_table"
  }
}
resource "aws_route" "public_internet_gw" {
  route_table_id = "${aws_route_table.example_route_table_pub.id}"
  destination_cidr_block = "${var.public_subnet_igw}"
  gateway_id = "${aws_internet_gateway.example_internet_gateway.id}"
}
resource "aws_route_table_association" "example_public_rt" {
  count = "${length(data.aws_availability_zones.available.names)}"
  route_table_id = "${aws_route_table.example_route_table_pub.id}"
  subnet_id = "${element(aws_subnet.example_subnet_public.*.id,count.index)}"
}
resource "aws_route_table" "example_route_table_priv" {
  vpc_id = "${aws_vpc.example_vpc.id}"
  route {
    cidr_block = "${var.public_subnet_igw}"
    gateway_id = "${aws_nat_gateway.example_nat_gw.id}"
  }
  tags {
    Name="example_route_table_priv"
  }
}
resource "aws_route_table_association" "example_private_rt" {
  count = "${length(data.aws_availability_zones.available.names)}"
  route_table_id = "${aws_route_table.example_route_table_priv.id}"
  subnet_id = "${element(aws_subnet.example_subnet_private.*.id,count.index)}"
}

resource "aws_eip" "example_nt_gw_eip" {
  vpc = true
  tags {
    Name="example_eip"
  }
}
resource "aws_nat_gateway" "example_nat_gw" {
  allocation_id = "${aws_eip.example_nt_gw_eip.id}"
  subnet_id = "${element(aws_subnet.example_subnet_public.*.id,0)}"
}
