variable "vpc_id" {
  description = "The ID of the VPC where resources will be deployed"
  type        = string
}

variable "public_subnet_cidr" {
  description = "cidr of the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "cidr of the private subnet "
  type        = string
}
