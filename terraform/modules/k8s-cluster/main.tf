resource "aws_instance" "bastion" {
  ami           = var.ec2_ami_bastion
  instance_type = var.instance_type_bastion
  key_name      = var.key_name
  subnet_id     = var.public_subnet_id
  security_groups = [var.bastion_sg_id]
  associate_public_ip_address = true

  tags = {
    Name = "k8s-bastion"
  }
}

resource "aws_instance" "controller" {
  ami           = var.ec2_ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.private_subnet_id
  security_groups = [var.sg_id]
  iam_instance_profile = var.iam_instance_profile

  tags = {
    Name = "k8s-controller",
    k8s-role = "controller"
  }

  user_data = file("${path.module}/controller.sh")
}

resource "aws_instance" "worker" {
  ami           = var.ec2_ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.private_subnet_id
  security_groups = [var.sg_id]
  iam_instance_profile = var.iam_instance_profile

  tags = {
    Name = "k8s-worker",
    k8s-role = "worker"
  }

  user_data = templatefile("${path.module}/worker.sh", {
    controller_private_ip = aws_instance.controller.private_ip
  })
}
