SHELL = /bin/bash

.PHONY: workstation deps certs

workstation: deps certs

deps:
	(cd scripts && ./check_deps.sh)

certs:
	(cd scripts && ./create_certs.sh)

