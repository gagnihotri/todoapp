#!/bin/bash
set -e

# Install dependencies
sudo yum update -y
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker

# Disable SWAP
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Install Kubernetes
sudo tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

sudo yum install -y kubelet kubeadm kubectl cri-tools kubernetes-cni
sudo systemctl enable kubelet
sudo systemctl start kubelet

CONTROLLER_IP="${controller_private_ip}"

# Wait for SSH to be available
while ! nc -z $CONTROLLER_IP 22; do   
  sleep 5
done


# Fetch join command from controller node
JOIN_COMMAND=$(ssh -o StrictHostKeyChecking=no -i /home/ec2-user/.ssh/id_rsa ec2-user@$CONTROLLER_IP "cat /tmp/k8s_join_command.sh")

sudo $JOIN_COMMAND
