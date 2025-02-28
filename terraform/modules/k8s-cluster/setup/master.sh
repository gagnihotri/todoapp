# Run kubeadm init
kubeadm init --pod-network-cidr=10.244.0.0/16

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