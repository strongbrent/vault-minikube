#!/usr/bin/env bash

set -e

. lib/functions.sh

# --- Helper Functions ---------------------------------------------------

# DESC: checks if a specified binary exists in the search path
# ARGS: $1 (REQ): name of the specified binary
# OUT: None
check_binary() {

    if ! command -v "${1}"; then
        error "ERROR: Can't find ${1} in your PATH"
        error "Please install ${1}"
        exit -1
    fi

    info "${1} is in your PATH"
}


# --- Main Function ------------------------------------------------------
main() {

    echo ""
    echo "--- Checking for required binaries ---"
    local -r deps=(
        "docker"
        "kubectl"
        "minikube"
        "consul"
        "vault"
        "go"
        "cfssl"
    )

    # check for required binaries
    for dep in "${deps[@]}"
    do
        check_binary "${dep}"
    done
}


main $@
