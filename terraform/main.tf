module "network" {
  source              = "./modules/network"

  availability_zone   = var.availability_zone
  vpc_cidr_block      = vpc_cidr_block
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "security" {
  source   = "./modules/security-groups"

  vpc_id   = module.network.vpc_id
  private_subnet_id    = module.network.private_subnet_id
}

module "iam" {
  source = "./modules/iam"
}

module "k8s-cluster" {
  source               = "./modules/k8s-cluster"
  
  instance_type_bastion = var.instance_type_bastion
  instance_type        = var.instance_type
  key_name             = var.key_name
  ec2_ami_bastion      = var.ec2_ami_bastion
  ec2_ami              = var.ec2_ami
  public_subnet_id     = module.network.public_subnet_id
  private_subnet_id    = module.network.private_subnet_id
  bastion_sg_id        = module.network.bastion_sg_id
  sg_id                = module.security.sg_id
  iam_instance_profile = module.iam.iam_instance_profile
}
