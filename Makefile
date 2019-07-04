SHELL = /bin/bash

.PHONY: deps

deps:
	(cd scripts && ./check_deps.sh)

