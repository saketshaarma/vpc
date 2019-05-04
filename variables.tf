variable "aws_secret_key" {
  description = "AWS IAM secret key for accessing AWS API"
}

variable "aws_access_key" {
  description = "AWS access key for accessing AWS API"
}

variable "aws_region" {
  description = "aws region in which deployment needs to be done"
}
variable "aws_vpc_cidr" {
  description = "AWS VPC CIDR which you want to create"
  default = "10.0.0.0/16"
}

variable "public_cidr" {
  default = "0.0.0.0/0"
}
