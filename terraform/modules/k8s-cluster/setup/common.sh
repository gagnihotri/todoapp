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

# Enable IP forward
grep -qxF 'net.ipv4.ip_forward = 1' /etc/sysctl.conf || echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
sysctl -p

# Download and extract containerd
CONTAINERD_VERSION="1.7.4"
CONTAINERD_TARBALL="containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz"

if [ ! -f "/usr/local/bin/containerd" ]; then
    wget https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/${CONTAINERD_TARBALL}
    tar -C /usr/local -xzf ${CONTAINERD_TARBALL}
    rm -f ${CONTAINERD_TARBALL}
else
    echo "Containerd already installed, skipping..."
fi

SERVICE_FILE="/usr/local/lib/systemd/system/containerd.service"
if [ ! -f "$SERVICE_FILE" ]; then
    wget -q -O containerd.service "https://raw.githubusercontent.com/containerd/containerd/v${CONTAINERD_VERSION}/containerd.service"
    mkdir -p /usr/local/lib/systemd/system
    mv containerd.service "$SERVICE_FILE"

    # Reload systemd only if a new file was added
    systemctl daemon-reload
    echo "Containerd service file updated and systemd reloaded."
else
    echo "Containerd service file already exists. Skipping download."
fi

mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl enable --now containerd
systemctl restart containerd

RUNC_VERSION="1.2.3"  # Set desired runc version
RUNC_BIN="/usr/local/sbin/runc"
if [ -x "$RUNC_BIN" ] && [ "$($RUNC_BIN --version | awk 'NR==1 {print $3}')" = "$RUNC_VERSION" ]; then
    echo "runc v$RUNC_VERSION is already installed. Skipping."
else
    echo "Installing runc v$RUNC_VERSION..."
    wget -q "https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.amd64"
    install -m 755 runc.amd64 "$RUNC_BIN"
    rm -f runc.amd64
    echo "runc v$RUNC_VERSION installed successfully."
fi

echo "-------------Installing CNI Plugins-------------"

# Define variables
CNI_VERSION="1.6.2"
CNI_TARBALL="cni-plugins-linux-amd64-v${CNI_VERSION}.tgz"
CNI_DIR="/opt/cni/bin"

mkdir -p ${CNI_DIR}
if [ ! -f "${CNI_DIR}/bridge" ]; then
  echo "Downloading CNI plugins..."
  curl -O -L https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/${CNI_TARBALL}
  tar Cxzvf ${CNI_DIR} ${CNI_TARBALL}
  rm -f ${CNI_TARBALL}
  echo "CNI plugins installed successfully!"
else
  echo "CNI plugins already installed."
fi

modprobe br_netfilter
echo "br_netfilter" | sudo tee -a /etc/modules-load.d/modules.conf
echo "net.bridge.bridge-nf-call-iptables = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo mkdir -p -m 755 /etc/apt/keyrings
# Check if the key file already exists
if [ ! -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]; then
  # Download the key if it doesn't exist
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  # Add the Kubernetes repository to the sources list
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
fi

apt-get update -y
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl