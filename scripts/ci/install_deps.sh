#!/usr/bin/env bash

set -e

# Script variables
## Short URL for kubectl v1.15.0
KUBECTL_URL="http://bit.ly/2KYvLcK"
KUBECTL_DEST="/usr/local/bin"

## Short URL for minikube v1.2.0
MINIKUBE_URL="http://bit.ly/2XjdOYe"
MINIKUBE_DEST="/usr/local/bin"

# Install kubectl
echo "Installing kubectl..."
curl -Lo kubectl "${KUBECTL_URL}"
chmod +x kubectl
sudo install kubectl "${KUBECTL_DEST}"

# Install minikube
echo "Installing minikube..."
curl -Lo minikube "${MINIKUBE_URL}"
chmod +x minikube
sudo install minikube "${MINIKUBE_DEST}"

