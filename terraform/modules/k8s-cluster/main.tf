resource "aws_instance" "bastion" {
  ami           = var.ami["bastion"]
  instance_type = var.instance_type["bastion"]
  key_name      = var.key_name
  subnet_id     = var.subnet["public"]
  vpc_security_group_ids  = [var.sg["bastion"]]
  iam_instance_profile = var.iam_instance_profile

  tags = {
    role = "bastion"
  }
}

resource "aws_instance" "master" {
  ami           = var.ami["master"]
  instance_type = var.instance_type["master"]
  key_name      = var.key_name
  subnet_id     = var.subnet["private"]
  vpc_security_group_ids  = [var.sg["master"]]
  iam_instance_profile = var.iam_instance_profile
  depends_on = [ aws_instance.master ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.private_key
    host        = self.private_ip
    bastion_host = aws_instance.bastion_public_ip
    bastion_user = "ec2-user"
    bastion_private_key = var.private_key
  }

  provisioner "file" {
    source      = "./master.sh"
    destination = "./master.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ./master.sh",
      "sudo sh ./master.sh k8s-master"
    ]
  }

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
  subnet_id     = var.subnet["private"]
  vpc_security_group_ids  = [var.sg["worker"]]
  iam_instance_profile = var.iam_instance_profile

  tags = {
    Name = "k8s-worker-${count.index}",
    k8s-role = "worker"
  }
}
