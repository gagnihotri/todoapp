resource "aws_security_group" "bastion_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bastion Security Group"
  }
}

resource "aws_security_group" "master_sg" {
  name        = "k8s_master_sg"
  vpc_id = var.vpc_id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.public_subnet_cidr]
  }

  ingress {
    description      = "API Server"
    from_port        = 6443
    to_port          = 6443
    protocol         = "tcp"
    cidr_blocks      = [var.private_subnet_cidr]
  }

  ingress {
    description      = "ETCD"
    from_port        = 2379
    to_port          = 2380
    protocol         = "tcp"
    cidr_blocks      = [var.private_subnet_cidr]
  }

  ingress {
    description      = "Kubelet API"
    from_port        = 10248
    to_port          = 10260
    protocol         = "tcp"
    cidr_blocks      = [var.private_subnet_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s_master_sg"
  }
}

resource "aws_security_group" "worker_sg" {
  name        = "k8s_worker_sg"
  vpc_id      = var.vpc_id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.public_subnet_cidr]
  }

  ingress {
    description      = "Kubelet API"
    from_port        = 10248
    to_port          = 10260
    protocol         = "tcp"
    cidr_blocks      = [var.private_subnet_cidr]
  }

  ingress {
    description      = "NodePort Services"
    from_port        = 30000
    to_port          = 32767
    protocol         = "tcp"
    cidr_blocks      = [var.private_subnet_cidr]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s_worker_sg"
  }
}
