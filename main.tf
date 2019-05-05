provider "aws" {
  secret_key = "${var.aws_secret_key}"
  access_key = "${var.aws_access_key}"
  region = "${var.aws_region}"
}
module "VPC" {
  source = "./modules/VPC"
  aws_vpc_cidr = "${var.aws_vpc_cidr}"
  public_cidr = "${var.public_cidr}"
}
module "iam" {
  source = "./modules/iam"
}

