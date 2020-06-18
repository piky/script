#!/bin/bash

## The script for safely remove worker node from Kubernetes cluster.
## Replace <node-name> before running.
kubectl get nodes
kubectl drain <node-name> --ignore-daemonsets --delete-local-data
kubectl delete node <node-name>

# running this script on removing node
kubeadm reset