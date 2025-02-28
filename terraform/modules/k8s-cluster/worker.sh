#!/bin/bash
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

# Install containerd service file from the correct version
wget https://raw.githubusercontent.com/containerd/containerd/v${CONTAINERD_VERSION}/containerd.service
mkdir -p /usr/local/lib/systemd/system
mv containerd.service /usr/local/lib/systemd/system/containerd.service
systemctl daemon-reload

mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl enable --now containerd
systemctl restart containerd

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

# Create the directory with proper permissions (if not already exists)
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

kubeadm version