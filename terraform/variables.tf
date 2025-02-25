variable "aws_region" {
  type        = string
  description = "AWS region where resources will be created"
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

variable "instance_type_bastion" {
  description = "EC2 instance type for bation host"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for Kubernetes nodes"
  type        = string
}

variable "key_name" {
  description = "The name of the SSH key pair to use for EC2 instances"
  type        = string
}

variable "ec2_ami_bastion" {
  description = "Amazon Machine Image (AMI) ID for the  bation EC2 instance"
  type        = string
}

variable "ec2_ami" {
  description = "Amazon Machine Image (AMI) ID for the EC2 instances"
  type        = string
}