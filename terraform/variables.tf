variable "region" {
  type        = string
  description = "AWS region where resources will be created"
}

variable "ami" {
  type = map(string)
  default = {
    master = "ami-0261755bbcb8c4a84"
    worker = "ami-0261755bbcb8c4a84"
    bastion = "ami-0261755bbcb8c4a84"
  }
}

variable "instance_type" {
  type = map(string)
  default = {
    master = "t2.micro"
    worker = "t2.micro"
    bastion = "t2.micro"
  }
}

variable "worker_instance_count" {
  type    = number
  default = 1
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

variable "key_name" {
  description = "The name of the SSH key pair to use for EC2 instances"
  type        = string
}