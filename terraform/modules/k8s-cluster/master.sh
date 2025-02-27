#!/bin/bash
set -e

# Set hostname
echo "-------------Setting Hostname-------------"
hostnamectl set-hostname "$1"

# Disable Swap
echo "-------------Disabling Swap-------------"
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Install Dependencies
echo "-------------Installing Required Packages-------------"
apt-get update -y
apt-get install -y curl wget gpg apt-transport-https ca-certificates

# Install Containerd
echo "-------------Installing Containerd-------------"
wget https://github.com/containerd/containerd/releases/download/v1.7.4/containerd-1.7.4-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-1.7.4-linux-amd64.tar.gz
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
mkdir -p /usr/local/lib/systemd/system
mv containerd.service /usr/local/lib/systemd/system/containerd.service
systemctl daemon-reload
systemctl enable --now containerd

mkdir -p /opt/cni/bin
curl -O -L https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.2.tgz
tar -C /opt/cni/bin -xzf cni-plugins-linux-amd64-v1.6.2.tgz

# Install Kubernetes Components
echo "-------------Installing Kubernetes (Kubelet, Kubeadm, Kubectl)-------------"
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update -y
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Initialize Kubernetes Master Node
echo "-------------Initializing Kubernetes Cluster-------------"
kubeadm init --pod-network-cidr=192.168.0.0/16

# Configure kubectl for Root User
echo "-------------Setting Up Kubeconfig-------------"
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Generate Join Command for Worker Nodes
echo "-------------Generating Join Command-------------"
kubeadm token create --print-join-command > /root/join-command.sh
chmod +x /root/join-command.sh
