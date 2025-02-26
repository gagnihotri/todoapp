
variable "ami" {
  type = map(string)
}

variable "instance_type" {
  type = map(string)
}

variable "worker_instance_count" {
  type    = number
  default = 1
}

variable "key_name" {
  description = "The name of the SSH key pair to use for EC2 instances"
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
