region                = "us-east-1"
key_name              = "javademokey"

ami = {
  master = "ami-053a45fff0a704a47"
  worker = "ami-053a45fff0a704a47"
  bation = "ami-053a45fff0a704a47"
}

instance_type = {
  master = "t2.micro"
  worker = "t2.micro"
  bation = "t2.micro"
}

vpc_cidr_block      = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"
availability_zone   = "us-east-1a"

worker_instance_count = 1
