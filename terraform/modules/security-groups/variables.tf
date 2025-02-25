variable "vpc_id" {
  description = "The ID of the VPC where resources will be deployed"
  type        = string
}

variable "private_subnet_cidr" {
  description = "The ID of the private subnet for private resources"
  type        = string
}
