variable "aws_vpc_cidr" {
  description = "AWS VPC CIDR which you want to create"
  default = "10.0.0.0/16"
}

variable "public_cidr" {
  default = "0.0.0.0/0"
}

data "aws_availability_zones" "all" {}

