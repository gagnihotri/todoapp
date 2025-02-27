resource "tls_private_key" "node-key" {
  algorithm   = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = tls_private_key.node-key.public_key_openssh
}

resource "aws_instance" "bastion" {
  ami           = var.ami["bastion"]
  instance_type = var.instance_type["bastion"]
  key_name      = aws_key_pair.deployer.key_name
  subnet_id     = var.subnet["public"]
  vpc_security_group_ids  = [var.sg["bastion"]]
  iam_instance_profile = var.iam_instance_profile

  tags = {
    Name = "bastion",
    role = "bastion"
  }
}

resource "local_sensitive_file" "private_key" {
  content  = var.private_key
  filename = "${path.root}/ec2-private-key.pem"
  file_permission = "0600"
}

resource "aws_instance" "master" {
  ami           = var.ami["master"]
  instance_type = var.instance_type["master"]
  key_name      = aws_key_pair.deployer.key_name
  subnet_id     = var.subnet["private"]
  vpc_security_group_ids  = [var.sg["master"]]
  iam_instance_profile = var.iam_instance_profile
  depends_on = [ aws_instance.bastion ]


  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.node-key.private_key_openssh
    host        = self.private_ip
    bastion_host = aws_instance.bastion.public_ip
    bastion_user = "ec2-user"
    bastion_private_key = tls_private_key.node-key.private_key_openssh
  }

  provisioner "file" {
    source = "./modules/k8s-cluster/master.sh"
    destination = "/home/ubuntu/master.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/master.sh",
      "sudo /home/ubuntu/master.sh k8s-master"
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
  key_name      = aws_key_pair.deployer.key_name
  subnet_id     = var.subnet["private"]
  vpc_security_group_ids  = [var.sg["worker"]]
  iam_instance_profile = var.iam_instance_profile

  tags = {
    Name = "k8s-worker-${count.index}",
    k8s-role = "worker"
  }
}
