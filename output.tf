output "aws_availability_zones" {
  value = "${data.aws_availability_zones.available.names}"
}
output "number_of_az" {
  value = "${length(data.aws_availability_zones.available.names)}"
}
