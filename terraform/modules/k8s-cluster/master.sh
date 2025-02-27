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
    tar -C /usr/local -xzf ${CONTAINERD_TARBALL}
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

mkdir -p ${CNI_DIR}
echo "Downloading CNI plugins..."
curl -O -L https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/${CNI_TARBALL}
tar Cxzvf ${CNI_DIR} ${CNI_TARBALL}
rm -f ${CNI_TARBALL}
echo "CNI plugins installed successfully!"

# Enable IP forward
grep -qxF 'net.ipv4.ip_forward = 1' /etc/sysctl.conf || echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
sysctl -p

# Create the directory with proper permissions (if not already exists)
sudo mkdir -p -m 755 /etc/apt/keyrings

# Check if the key file already exists
if [ ! -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]; then
  # Download the key if it doesn't exist
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
fi

# Add the Kubernetes repository to the sources list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

apt-get update -y
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl


# Run kubeadm init
kubeadm init --pod-network-cidr=192.168.0.0/16

# Set up kubeconfig for the ubuntu user (or your specific user)
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

echo "Kubernetes initialization complete!"

# Check if the join-command.sh file already exists
if [ ! -f /home/ubuntu/join-command.sh ]; then
  echo "Creating join command file..."

  # Create a new token and print the join command
  kubeadm token create --print-join-command > /home/ubuntu/join-command.sh
  
  # Make the script executable
  chmod +x /home/ubuntu/join-command.sh

  echo "Join command created and file made executable."
else
  echo "Join command file already exists, skipping creation."
fi

kubeadm version
kubectl version
kubelet --version

