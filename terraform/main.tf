module "network" {
  source = "./modules/network"

  availability_zone   = var.availability_zone
  vpc_cidr_block      = var.vpc_cidr_block
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "security" {
  source = "./modules/security-groups"

  vpc_id              = module.network.vpc_id
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "iam" {
  source = "./modules/iam"
}

locals {
  private_key = jsondecode(data.aws_secretsmanager_secret_version.private_key_version.secret_string)["ec2-key"]
}

module "k8s-cluster" {
  source = "./modules/k8s-cluster"

  worker_instance_count = var.worker_instance_count
  instance_type         = var.instance_type
  ami                   = var.ami
  key_name              = var.key_name
  iam_instance_profile  = module.iam.iam_instance_profile
  private_key           = local.private_key

  subnet = {
    private = module.network.private_subnet_id
    public  = module.network.public_subnet_id
  }

  sg = {
    bastion = module.security.bastion_sg
    master  = module.security.master_sg
    worker  = module.security.worker_sg
  }
}