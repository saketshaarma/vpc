resource "aws_vpc" "example_vpc" {
  cidr_block = "${var.aws_vpc_cidr}"
  enable_dns_support = true
  tags {
    Name="example_vpc"
  }
}
resource "aws_subnet" "example_public_subnet" {
  count = "${length(data.aws_availability_zones.all.names)}"
  availability_zone = "${data.aws_availability_zones.all.names[count.index]}"
  cidr_block = "${cidrsubnet(var.aws_vpc_cidr,8,count.index)}"
  vpc_id = "${aws_vpc.example_vpc.id}"
  map_public_ip_on_launch = true
  tags {
    Name="example_public_subnet"
  }
}
resource "aws_subnet" "example_private_subnet" {
  count = "${length(data.aws_availability_zones.all.names)}"
  availability_zone = "${data.aws_availability_zones.all.names[count.index]}"
  cidr_block = "${cidrsubnet(var.aws_vpc_cidr,8,length(data.aws_availability_zones.all.id)+count.index)}"
  vpc_id = "${aws_vpc.example_vpc.id}"
  map_public_ip_on_launch = false
  tags {
    Name="example_private_subnet"
  }
  depends_on = ["aws_subnet.example_public_subnet"]
}

resource "aws_internet_gateway" "example_inter_gw" {
  vpc_id = "${aws_vpc.example_vpc.id}"
  tags {
    Name="example_vpc_internet_gateway"
  }
}


resource "aws_route_table" "example_vpc_route_table_public" {
  vpc_id = "${aws_vpc.example_vpc.id}"
  route {
    cidr_block = "${var.public_cidr}"
    gateway_id = "${aws_internet_gateway.example_inter_gw.id}"
  }
  tags {
    Name="example_vpc_route_table_public"
  }
}

resource "aws_route_table_association" "example_public_route_table" {
  count = "${length(data.aws_availability_zones.all.names)}"
  route_table_id = "${aws_route_table.example_vpc_route_table_public.id}"
  subnet_id = "${element(aws_subnet.example_public_subnet.*.id,count.index)}"
}
resource "aws_route" "public_internet_gw" {
  route_table_id = "${aws_route_table.example_vpc_route_table_public.id}"
  destination_cidr_block = "${var.public_cidr}"
  gateway_id = "${aws_internet_gateway.example_inter_gw.id}"
}
resource "aws_eip" "example_eip_nat_gw" {
  vpc = true
  count = "${length(data.aws_availability_zones.all.names)}"
  tags {
    Name="example_eip_nat_gw.${count.index}"
  }
}

resource "aws_nat_gateway" "example_nat_gw" {
  count = "${length(data.aws_availability_zones.all.names)}"
  allocation_id = "${element(aws_eip.example_eip_nat_gw.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.example_public_subnet.*.id, count.index)}"
  depends_on = ["aws_internet_gateway.example_inter_gw"]
}

resource "aws_route_table" "example_vpc_route_table_private" {
  vpc_id = "${aws_vpc.example_vpc.id}"
  route {
    cidr_block = "${var.public_cidr}"
    nat_gateway_id = "${element(aws_nat_gateway.example_nat_gw.*.id, count.index)}"
  }
  tags {
    Name="example_vpc_route_table_private"
  }
}
resource "aws_route_table_association" "example_rt_private_pool" {
  count = "${length(data.aws_availability_zones.all.names)}"
  route_table_id = "${aws_route_table.example_vpc_route_table_private.id}"
  subnet_id = "${element(aws_subnet.example_private_subnet.*.id, count.index)}"
}
