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

echo "-------------Installing Containerd-------------"

# Define variables
CONTAINERD_VERSION="1.7.4"
CONTAINERD_TARBALL="containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz"

# Download and extract containerd
if [ ! -f "/usr/local/bin/containerd" ]; then
    wget https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/${CONTAINERD_TARBALL}
    tar -Cxzvf /usr/local -xzf ${CONTAINERD_TARBALL}
    rm -f ${CONTAINERD_TARBALL}
else
    echo "Containerd already installed, skipping..."
fi

# Install containerd service file
if [ ! -f "/usr/local/lib/systemd/system/containerd.service" ]; then
    wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
    mkdir -p /usr/local/lib/systemd/system
    mv containerd.service /usr/local/lib/systemd/system/containerd.service
    systemctl daemon-reload
    systemctl enable --now containerd
else
    echo "Containerd service already installed, skipping..."
fi

# Install runc
wget https://github.com/opencontainers/runc/releases/download/v1.2.3/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc
rm -f runc.amd64

echo "-------------Installing CNI Plugins-------------"

# Define variables
CNI_VERSION="1.6.2"
CNI_TARBALL="cni-plugins-linux-amd64-v${CNI_VERSION}.tgz"
CNI_DIR="/opt/cni/bin"

# Ensure the directory exists
mkdir -p ${CNI_DIR}

# Check if CNI plugins are already installed
if [ ! -f "${CNI_DIR}/bridge" ]; then
    echo "Downloading CNI plugins..."
    curl -O -L https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/${CNI_TARBALL}
    tar -C ${CNI_DIR} -xzf ${CNI_TARBALL}
    rm -f ${CNI_TARBALL}
    echo "CNI plugins installed successfully!"
else
    echo "CNI plugins already installed, skipping..."
fi

# Enable IP forward
grep -qxF 'net.ipv4.ip_forward = 1' /etc/sysctl.conf || echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
sysctl -p

# Install Kubernetes Components
echo "-------------Installing Kubernetes (Kubelet, Kubeadm, Kubectl)-------------"
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get update -y
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

echo "-------------Printing Kubeadm version-------------"
kubeadm version
