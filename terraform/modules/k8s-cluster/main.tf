resource "tls_private_key" "node-key" {
  algorithm   = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = tls_private_key.node-key.public_key_openssh
}

resource "null_resource" "create-pem" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOT
      echo '${tls_private_key.node-key.private_key_openssh}' > ./node-key.pem
      chmod 600 ./node-key.pem
    EOT
  }

  depends_on = [tls_private_key.node-key]
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

  depends_on = [tls_private_key.node-key]
}

resource "null_resource" "copy-pem" {
  triggers = {
    always_run = "${timestamp()}"  # Generates a new timestamp every apply
  }

  provisioner "file" {
    source      = "./node-key.pem"
    destination = "/home/ec2-user/node-key.pem"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.node-key.private_key_openssh
      host        = aws_instance.bastion.public_ip
    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.node-key.private_key_openssh
      host        = aws_instance.bastion.public_ip
    }

    inline = [
      "chmod 600 /home/ec2-user/node-key.pem"  # Secure the private key on the bastion
    ]
  }

  depends_on = [aws_instance.bastion, null_resource.create-pem]
} 

resource "aws_instance" "master" {
  ami           = var.ami["master"]
  instance_type = var.instance_type["master"]
  key_name      = aws_key_pair.deployer.key_name
  subnet_id     = var.subnet["private"]
  vpc_security_group_ids  = [var.sg["master"]]
  iam_instance_profile = var.iam_instance_profile

  tags = {
    Name = "k8s-master",
    k8s-role = "master"
  }

  depends_on = [tls_private_key.node-key]
}

resource "null_resource" "setup-master" {
  
  triggers = {
    script_hash = sha256(join("", [
      file("./modules/k8s-cluster/setup/common.sh"),
      file("./modules/k8s-cluster/setup/master.sh")
    ]))
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.node-key.private_key_openssh
    host        = aws_instance.master.private_ip
    bastion_host = aws_instance.bastion.public_ip
    bastion_user = "ec2-user"
    bastion_private_key = tls_private_key.node-key.private_key_openssh
  }

  provisioner "file" {
    source = "./modules/k8s-cluster/setup/"
    destination = "/home/ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ubuntu/common.sh && sudo /home/ubuntu/common.sh k8s-master",
      "sudo chmod +x /home/ubuntu/master.sh && sudo /home/ubuntu/master.sh"
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.node-key.private_key_openssh
      host        = aws_instance.bastion.public_ip
    }

    inline = [
      "scp -o StrictHostKeyChecking=no -i /home/ec2-user/node-key.pem ubuntu@${aws_instance.master.private_ip}:/home/ubuntu/join-command.sh /home/ec2-user/join-command.sh",
      "sudo chmod +x /home/ec2-user/join-command.sh"
    ]
  }

  depends_on = [ null_resource.copy-pem ]
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

  depends_on = [tls_private_key.node-key]
}

resource "null_resource" "setup-worker" {
  count = var.worker_instance_count

  triggers = {
    script_hash = sha256(file("./modules/k8s-cluster/setup/common.sh"))
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.node-key.private_key_openssh
    host        = aws_instance.worker[count.index].private_ip
    bastion_host = aws_instance.bastion.public_ip
    bastion_user = "ec2-user"
    bastion_private_key = tls_private_key.node-key.private_key_openssh
  }

  provisioner "file" {
    source = "./modules/k8s-cluster/setup/common.sh"
    destination = "/home/ubuntu/common.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/common.sh",
      "sudo /home/ubuntu/common.sh k8s-worker"
    ]
  }

  depends_on = [ null_resource.copy-pem ]
}

resource "null_resource" "join-workers" {
  count = var.worker_instance_count

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.node-key.private_key_openssh
      host        = aws_instance.bastion.public_ip
    }

    inline = [
      # Copy the join command from the bastion to the worker node
      "scp -o StrictHostKeyChecking=no -i /home/ec2-user/node-key.pem /home/ec2-user/join-command.sh ubuntu@${aws_instance.worker[count.index].private_ip}:/home/ubuntu/join-command.sh",
      "ssh -o StrictHostKeyChecking=no -i /home/ec2-user/node-key.pem ubuntu@${aws_instance.worker[count.index].private_ip} 'chmod +x /home/ubuntu/join-command.sh'",
      "ssh -o StrictHostKeyChecking=no -i /home/ec2-user/node-key.pem ubuntu@${aws_instance.worker[count.index].private_ip} 'sudo /home/ubuntu/join-command.sh'"
    ]
  }

  depends_on = [ null_resource.setup-worker ]
}