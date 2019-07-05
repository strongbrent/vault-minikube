# Hashicorp's Vault and Consul using Kubernets

[![Build Status](https://travis-ci.org/strongbrent/vault-minikube.svg?branch=master)](https://travis-ci.org/strongbrent/vault-minikube)

Running Hashicorp's Running Vault and Consul in Minikube.

Based on this blog [post](https://testdriven.io/blog/running-vault-and-consul-on-kubernetes/) create by [Michael Herman](https://github.com/mjhea0).

**NOTE**: these instuctions assume that your workstation is a Mac. For example, this installation was manually tested on a 2017 MacBook (3.1GHz Intel Core I7 with 16GB of memory) running macOS Mojave (v10.14.2). All automated tested was conducted using Travis CI (xenial with docker and minikube installed using `--vm-driver=none`).

## Requirements
It is much easier to follow these instruction if you already have [Homebrew](https://brew.sh/) installed on your Mac. Click this [link](https://brew.sh/) for installation instructions.

| Requirement | My Version | Installation Instrunctions |
| ----------- | ------- | -------------------------- |
| [Docker](https://docs.docker.com/docker-for-mac/install/) | 18.09.1 | `brew install docker` |
| [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) | Client Version: v1.15.0 | `brew install kubectl` |
| [VirtualBox](https://www.virtualbox.org/wiki/Downloads) | TODO | `brew cask install virtualbox` | 
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

TODO: More to follow...
