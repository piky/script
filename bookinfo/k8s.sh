#!/bin/bassh

## Reference 1) https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/ in CentOS, RHEL or Fedora section.
## Reference 2) https://medium.com/platformer-blog/kubernetes-on-centos-7-with-firewalld-e7b53c1316af

## Disable swap
swapoff -a
sed -i 's/^\(.*swap.*\)$/#\1/' /etc/fstab
echo "Swap is off"

## Prepare system environment
### Load netfilter probe specifically
modprobe br_netfilter
lsmod | grep br_netfilter

## disable SELinux. If you want this enabled, comment out the next 2 lines. But you may encounter issues with enabling SELinux
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

## Install kuberentes packages
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum -y install kubectl kubelet kubeadm --disableexcludes=kubernetes
systemctl enable --now kubelet
echo "kubelet is now $(systemctl is-enabled kubelet)."
echo "kubelet is now $(systemctl is-active kubelet)."

## Noticed that kubelet is now expectedly restarting every few seconds, as it waits in a crashloop for kubeadm to tell it what to do.

## Enable IP Forwarding
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sysctl --system

## Testing connectivity by pulling required images beforehand.
kubeadm config images pull

HOST_IPv4=$(ip -4 addr show enp3s4f0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$HOST_IPv4 --control-plane-endpoint=$(hostname --fqdn)

mkdir -p $HOME/.kube/
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

kubectl taint nodes --all node-role.kubernetes.io/master-
sleep 1m # Waits a minute.
echo "Waits for a minute"
kubectl cluster-info
kubectl get nodes -o wide

## Install Calico CNI
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
echo "Waits for 3 minutes"
sleep 3m # Waits 3 minutes.
kubectl get pods --all-namespaces