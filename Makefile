SHELL = /bin/bash

.PHONY: workstation deps certs consul clean destroy

workstation: deps certs consul vault

deps:
	(cd scripts && ./check_deps.sh)

certs:
	(cd scripts && ./create_certs.sh)

consul:
	(cd scripts && ./deploy_consul.sh)

vault:
	(cd scripts && ./deploy_vault.sh)

clean:
	(cd scripts && ./cleanup.sh)

destroy: clean
	$(info --- Deleting Minikube ---)
	minikube delete

