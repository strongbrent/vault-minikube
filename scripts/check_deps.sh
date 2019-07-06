#!/usr/bin/env bash

. lib/functions.sh

# --- Helper Functions ---------------------------------------------------

# DESC: checks if a specified binary exists in the search path
# ARGS: $1 (REQ): name of the specified binary
# OUT: NONE
check_binary() {

    if ! command -v "${1}" &> /dev/null; then
        error "ERROR: Can't find ${1} in your PATH"
        error "Please install ${1}"
        exit -1
    fi

    info "${1} is in your PATH"
}


# DESC: ensure that docker is running (forget about Windows)
# ARGS: NONE
# OUT:  NONE
check_docker_running() {
    # From https://gist.github.com/peterver/ca2d60abc015d334e1054302265b27d9
    docker_ping=$(curl -s --unix-socket /var/run/docker.sock http://ping > /dev/null)
    STATUS=$?

    if [ "${STATUS}" == "7" ]; then
        error "ERROR: The docker service is NOT running. Please start docker"
        exit -1
    fi

    info "docker: service is running"
}


# DESC: ensure that minikube is running
# ARGS: NONE
# OUT:  NONE
check_minikube_running() {
    if ! minikube status &> /dev/null; then
        error "ERROR: minikube service is NOT running. Please start minikube"
        exit -1
    fi

    info "minikube: service is running"
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

    echo ""
    echo "--- Checking for required services ---"
    check_docker_running
    check_minikube_running
}

main $@

