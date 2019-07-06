SHELL = /bin/bash

.PHONY: workstation deps certs consul

workstation: deps certs consul

deps:
	(cd scripts && ./check_deps.sh)

certs:
	(cd scripts && ./create_certs.sh)

consul:
	(cd scripts && ./deploy_consul.sh)

