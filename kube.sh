#!/bin/bash

# Устанавливаем зависимости для apt:
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
#Настраиваем репозиторий:
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
#Устанавливаем пакеты
sudo apt-get update
sudo apt-get install -y  kubeadm 
#sudo apt-get install -y kubelet  kubectl

# turn off swap
#swapoff -a
#sed -i '/ swap / s/^/#/' /etc/fstab

# Fix `container runtime is not running: output: E1224` 

# rm /etc/containerd/config.toml
# systemctl restart containerd

# # create systemd config for kubelet
# cat << _EOF_ > /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf
# [Service]
# ExecStart=
# ExecStart=/usr/bin/kubelet --address=127.0.0.1 --pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true
# Restart=always
# _EOF_

# # reload systemd and start kublet
# systemctl daemon-reload
# systemctl restart kubelet
