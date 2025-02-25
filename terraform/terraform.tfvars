vpc_cidr_block      = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"
availability_zone   = "us-east-1a"

aws_region            = "us-east-1"
instance_type_bastion = "t2.micro"
instance_type         = "t2.micro"
key_name              = "javademokey"
ec2_ami_bastion       = "ami-053a45fff0a704a47"
ec2_ami               = "ami-053a45fff0a704a47"
