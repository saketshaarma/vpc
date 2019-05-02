variable "aws_vpc_cidr" {
  description = "AWS VPC CIDR range"
  default = "10.0.0.0/16"
}
data "aws_availability_zones" "available" {}

variable "public_subnet_igw" {
  description = "Gateway Whitelisting"
  default = "0.0.0.0/0"
}
