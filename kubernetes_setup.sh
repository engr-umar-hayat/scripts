#!/bin/bash
# This script setup kubernetes  and its dependencies from scratch
sudo apt-get update

# Kubernetes cluster setup on Ubuntu 18.04 LTS
sudo apt-get install -y docker.io
sudo systemctl start docker

# Turn swap off
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Install kubernetes
sudo apt-get install -y apt-transport-https && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

# kubectl install: kubeadm kubelet, kubectl, and kubernetes-cni
sudo apt-get install kubeadm=1.13.4-00 kubelet=1.13.4-00 kubectl=1.13.4-00 kubernetes-cni=0.6.0-00

# To install latest versions: kubeadm kubelet, kubectl, and kubernetes-cni
# sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni

# Update iptables
sudo sysctl net.bridge.bridge-nf-call-iptables=1

# Run cluster (without remote kubectl access)
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Run cluster with remote kubectl access
# sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-cert-extra-sans=192.0.0.1

# Cluster permissions:
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Running system dependencies of kubernetes
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml

# Link to latest flannel documentation
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Verify kubernetes pods status for all namespaces
kubectl get pods --all-namespaces

# Make master node as single node cluster
kubectl taint nodes --all node-role.kubernetes.io/master-

# Troubleshooting Commands
#sudo systemctl stop kubelet
#sudo systemctl stop docker
#sudo iptables --flush
#sudo iptables -tnat --flush
#sudo systemctl start kubelet
#sudo systemctl start docker


# If  below error occur  then export KUBECONFIG (below)
# unable to recognize "STDIN": Get https://192.168.8.102:6443/api?timeout=32s:
# x509: certificate signed by unknown authority (possibly because of "crypto/rsa:
# verification error" while trying to verify candidate authority certificate "kubernetes")

# Run below command
# export KUBECONFIG=/etc/kubernetes/kubelet.conf

# error: Error loading config file "/etc/kubernetes/kubelet.conf":
# open /etc/kubernetes/kubelet.conf: permission denied

#  Run below command
# sudo chown $(id -u):$(id -g) /etc/kubernetes/kubelet.conf

## To Teardown
# Run below cmmand
# $> sudo su
#> kubeadm reset
#> rm -rf $HOME/.kube /etc/kubernetes
# References: https://bit.ly/2JC1i4N

# References:
# https://blog.emumba.com/kubernetes-cluster-setup-on-ubuntu-16-04-ece04f9cd841
# https://raaaimund.github.io/tech/2018/10/23/create-single-node-k8s-cluster/
# https://medium.com/@vivek_syngh/setup-a-single-node-kubernetes-cluster-on-ubuntu-16-04-6412373d837a/