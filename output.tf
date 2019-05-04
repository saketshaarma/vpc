output "aws_vpc_name" {
  value = "${aws_vpc.example_vpc.id}"
}

output "aws_availablity-zone" {
  value = "${data.aws_availability_zones.all.names}"
}

output "aws_public_subnet" {
  value = "${aws_subnet.example_public_subnet.*.cidr_block}"
}

output "main_route_table" {
  value = "${aws_vpc.example_vpc.main_route_table_id}"
}

output "nat_gw_eip_ip" {
  value = "${aws_eip.example_eip_nat_gw.*.id}"
}

