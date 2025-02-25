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

variable "public_subnet_id" {
  description = "The ID of the private subnet where the EC2 instances will be deployed"
  type        = string
}

variable "private_subnet_id" {
  description = "The ID of the private subnet where the EC2 instances will be deployed"
  type        = string
}

variable "bastion_sg_id" {
  description = "The security group ID to associate with the bastion host EC2 instance"
  type        = string
}

variable "sg_id" {
  description = "The security group ID to associate with the EC2 instances"
  type        = string
}

variable "iam_instance_profile" {
  description = "The IAM instance profile to attach to the EC2 instances"
  type        = string
}
