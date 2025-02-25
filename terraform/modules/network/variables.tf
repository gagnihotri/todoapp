variable "region" {
    type = "region"
    description = "aws region"
}

variable "vpc_cidr_block" {
  type    = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr" {
  type    = string
  description = "CIDR block for the public subnet"
}

variable "private_subnet_cidr" {
  type    = string
  description = "CIDR block for the private subnet"
}

variable "availability_zone" {
  type    = string
  description = "AWS Availability Zone"
}
