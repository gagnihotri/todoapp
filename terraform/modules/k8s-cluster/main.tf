resource "aws_instance" "bastion" {
  ami           = var.ami["bation"]
  instance_type = var.instance_type["bation"]
  key_name      = var.key_name
  subnet_id     = var.public_subnet_id
  vpc_security_group_ids  = [var.bastion_sg_id]
  associate_public_ip_address = true

  tags = {
    Name = "k8s-bastion"
  }
}

resource "aws_instance" "master" {
  ami           = var.ami["master"]
  instance_type = var.instance_type["master"]
  key_name      = var.key_name
  subnet_id     = var.private_subnet_id
  vpc_security_group_ids  = [var.sg_id]
  iam_instance_profile = var.iam_instance_profile

  tags = {
    Name = "k8s-master",
    k8s-role = "master"
  }
}

resource "aws_instance" "worker" {
  count         = var.worker_instance_count

  ami           = var.ami["worker"]
  instance_type = var.instance_type["worker"]
  key_name      = var.key_name
  subnet_id     = var.private_subnet_id
  vpc_security_group_ids  = [var.sg_id]
  iam_instance_profile = var.iam_instance_profile

  tags = {
    Name = "k8s-worker-${count.index}",
    k8s-role = "worker"
  }
}
