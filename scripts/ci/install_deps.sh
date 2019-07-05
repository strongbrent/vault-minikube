#!/usr/bin/env bash

set -e

# --- Script variables ---------------------------------------------------
DEST_PATH="/usr/local/bin"


# --- Helper Functions ---------------------------------------------------

# DESC: installs specified program binaries to DEST_PATH location
# ARGS: $1 (REQ): name of the specified program binary
#       $2 (REQ): program package source URL
# OUT:  NONE
install_bin() {
    echo ""
    echo "Installing: ${1}"
    curl -Lo "${1}" "${2}"

    # Test to see if the file is complressed
    local -r file_type=$(file ${1} | awk '{print $2}')

    if [[ ${file_type} == "Zip" ]]; then
        unzip -o "${1}"
    fi

    chmod +x "${1}"
    sudo install "${1}" "${DEST_PATH}"

    # Sanity test
    echo "Sanity test for: ${1}"
    command -v "${1}"

    # Clean up
    rm -fv ./${1}
}


# --- Main Function ------------------------------------------------------
main() {
    # Install unzip
    sudo apt update && sudo apt install -y unzip

    # Install consul (client)
    # Short URL for consul 1.5.2
    CONSUL_URL="http://bit.ly/2JnWYlQ"
    install_bin consul "${CONSUL_URL}"

    # Install vault (client)
    # Short URL for vault 1.1.3
    VAULT_URL="http://bit.ly/327xCRH"
    install_bin vault "${VAULT_URL}"

    # Install kubectl
    # Short URL for kubectl v1.15.0
    KUBECTL_URL="http://bit.ly/2KYvLcK"
    install_bin kubectl "${KUBECTL_URL}"

    # Install minikube
    # Short URL for minikube v1.2.0
    MINIKUBE_URL="http://bit.ly/2XjdOYe"
    install_bin minikube "${MINIKUBE_URL}"

    # Install Cloudflare's cfssl toolkit
    echo ""
    echo "Installing Cloudflare's cfssl toolkit"
    go get -u github.com/cloudflare/cfssl/cmd/cfssl
    go get -u github.com/cloudflare/cfssl/cmd/cfssljson

    echo ""
    echo "Sanity test for: cfssl"
    command -v cfssl

    echo ""
    echo "Sanity test for: cfssljson"
    command -v cfssljson
}

main $@
