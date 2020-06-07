#!/bin/bash

# Install Docker CE on minimal-installed CentOS/RHEL 8 
## Reference source 1: https://kubernetes.io/docs/setup/production-environment/container-runtimes/
## Reference source 2: https://linuxconfig.org/how-to-install-docker-in-rhel-8

## Set up the repository
### Install required packages
yum -y update
yum install -y yum-utils device-mapper-persistent-data lvm2 iproute-tc vim

# Add the Docker repository
yum-config-manager --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo

yum install -y https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.13-3.2.el7.x86_64.rpm
yum install -y docker-ce docker-ce-cli containerd.io

## Create /etc/docker
mkdir /etc/docker

# Set up the Docker daemon to use 'systemd' instead of 'cgroupfs'
cat > /etc/docker/daemon.json << EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

systemctl enable --now docker
echo "kubelet is now $(systemctl is-enabled docker)."
echo "kubelet is now $(systemctl is-active docker)."

## Disabling system firewalld to allow DNS resolution inside Docker containers,
#systemctl disable firewalld

## It's wisely and security to add an user to Docker group.
# usermod -aG docker <username>

## [Caveat] if set 'systemd' as above to avoid warning message,  hairpinning mode will fail.
## And that causes Istio installation : Pod Readiness probe failed with HTTP 503 error.
## So set hairpin mode with root privilege.
#for intf in /sys/devices/virtual/net/docker0/brif/*; do echo 1 > $intf/hairpin_mode; done

## Or set it in CNI manifest YAML file:
# "type": "cni_name",
# "delegate": {
#        "hairpinMode": true,
#       }