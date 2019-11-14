# Hashicorp's Vault and Consul using Kubernetes

[![Build Status](https://travis-ci.org/strongbrent/vault-minikube.svg?branch=master)](https://travis-ci.org/strongbrent/vault-minikube)

Running Hashicorp's Vault and Consul in Minikube.

Based on this blog [post](https://testdriven.io/blog/running-vault-and-consul-on-kubernetes/) created by [Michael Herman](https://github.com/mjhea0).

**NOTE**: these instuctions assume that your workstation is a Mac. For example, this installation was manually tested on a 2017 MacBook (3.1GHz Intel Core I7 with 16GB of memory) running macOS Mojave (v10.14.2). All automated testing was conducted using Travis CI (xenial with docker and minikube installed using `--vm-driver=none`).

## Requirements
It is much easier to follow these instruction if you already have [Homebrew](https://brew.sh/) installed on your Mac. Click this [link](https://brew.sh/) for installation instructions.

| Requirement | My Version | Installation Instrunctions |
| ----------- | ------- | -------------------------- |
| [Docker](https://docs.docker.com/docker-for-mac/install/) | 18.09.1 | `brew install docker` |
| [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) | Client Version: v1.15.0 | `brew install kubectl` |
| [VirtualBox](https://www.virtualbox.org/wiki/Downloads) | 5.2.22 | `brew cask install virtualbox` | 
| [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) | v1.2.0 | `brew cask install minikube` |
| Hashicorp [consul](https://www.consul.io/) client | v1.4.0 | `brew install consul` |
| Hashicorp [vault](https://www.vaultproject.io/) client| v1.0.2 | `brew install vault` |
| [Golang](https://golang.org/doc/install) | 1.11.5 | `brew install go --cross-compile-common` |

### Configuring Golang

Make certain that you remember to set your `GOPATH` variable.  

Example:
```
$ mkdir $HOME/go
$ export GOPATH=$HOME/go
$ export PATH=$PATH:$GOPATH/bin
```

### Installing Cloudflare's cfssl toolkit
Once you've got GO properly installed and configured, just run:
```
$ go get -u github.com/cloudflare/cfssl/cmd/cfssl
$ go get -u github.com/cloudflare/cfssl/cmd/cfssljson
```
And that's it. The scripts included in this repository should take care of the rest.

## Getting Started

### Start the cluster
```
$ minikube start --vm-driver=virtualbox
$ minikube dashboard
```

### Clone this repo
Kind of goes without saying. Clone and then navigate as follows:
```
$ cd vault-kubernetes
```

### Deploy the cluster
```
$ make workstation
```

## Quick Test
Set Vault specific Environment Variables:
```
export VAULT_ADDR=https://127.0.0.1:8200
export VAULT_CACERT="scripts/certs/ca.pem"
```

Ensure Vault client is installed. Then init Vault using a single key (DO NOT do this in production):
```
vault operator init -key-shares=1 -key-threshold=1
```

Take note of the unseal key and the initial root token. For example:
```
Unseal Key 1: F0Snz/ubK2IEdQ4a8WGECianyueTiIwsKAvV0XXYp4Y=

Initial Root Token: 8GIwICNI9Pn3dO9JFNnuUhTi
```

Unseal Vault:
```
$ vault operator unseal
Unseal Key (will be hidden): <paste Unseal Key 1>
```

Authenticate with the root token:
```
$ vault login
Token (will be hidden): <paste Initial Root Token>
```

Enable the kv secrets engine at: secret/
```
$ vault secrets enable -path=secret/ kv

Success! Enabled the kv secrets engine at: secret/
```

Create a test secret:
```
$ vault kv put secret/precious mysecret=mysecretvalue

Success! Data written to: secret/precious
```

Read the test secret:
```
$ vault kv get secret/precious
=== Data ===
Key       Value
---       -----
mysecret  mysecretvalue
```

## Tearing Everything Down

If you want to remove all the Kubernetes resources and start all over (without creating a new minikube cluster), then run the following:
```
$ make clean
```

Now you can run `make workstation` to re-deploy fresh Kubernetes resources again.

**HOWEVER**, if you want to tear down the whole works and delete minikube, you can type:
```
$ make destroy
```

