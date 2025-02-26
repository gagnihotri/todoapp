
variable "ami" {
  type = map(string)
}

variable "instance_type" {
  type = map(string)
}

variable "subnet" {
  type = map(string)
}

variable "sg" {
  type = map(string)
}

variable "key_name" {
  description = "The name of the SSH key pair to use for EC2 instances"
  type        = string
}

variable "iam_instance_profile" {
  description = "The IAM instance profile to attach to the EC2 instances"
  type        = string
}

variable "worker_instance_count" {
  type    = number
  default = 1
}
