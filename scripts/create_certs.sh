#!/usr/bin/env bash

. lib/functions.sh

# --- Helper Functions ---------------------------------------------------

# DESC: use cfssl to create a certificate authority
# ARGS: $1 (REQ): cert destination path
#       $2 (REQ): config file (json) path
# OUT:  NONE
create_ca() {

    if [[ ! -f ./${1}.pem ]]; then
        cfssl gencert -initca ./${2} | cfssljson -bare ./${1}
        success "Created CA: ${1}"
        return
    fi

    info "Already created CA: ${1}"
}


# DESC: use cfssl to create priv key and TLS certs
# ARGS: $1 (REQ): certs dir
#       $2 (REQ): config dir
#       $3 (REQ): cert file name
# OUT:  NONE
create_certs() {
    if [[ ! -f ./${1}/${3}.pem ]]; then
        cfssl gencert \
            -ca=${1}/ca.pem \
            -ca-key=${1}/ca-key.pem \
            -config=${2}/ca-config.json \
            -profile=default \
            ${2}/${3}-csr.json | cfssljson -bare ./${1}/${3}
        success "Created PK and TLS for: ${3}"
        return
    fi

    info "Already created PK and TLS for: ${3}"
}


# DESC: creates specified directories
# ARGS: $1 (REQ): name of the dir to be created
# OUT:  NONE
make_dirs() {
    if [[ ! -d "${1}" ]]; then
        mkdir -p "${1}"
        success "Created dir: ${1}"
        return
    fi

    info "Already created dir: ${1}"
}


# --- Main Function ------------------------------------------------------
main() {

    # main function vars/constants
    local -r certs_dir="certs"
    local -r conf_dir="config"
    local -r consul_cert="consul"
    local -r vault_cert="vault"

    echo ""
    echo "--- Creating certificates directory ---"
    make_dirs ${certs_dir}

    echo ""
    echo "--- Creating certificate authority ---"
    create_ca "${certs_dir}/ca" "${conf_dir}/ca-csr.json"

    echo ""
    echo "--- Creating private key and TLS cert for consul ---"
    create_certs "${certs_dir}" "${conf_dir}" "${consul_cert}"

    echo ""
    echo "--- Creating private key and TLS cert for vault ---"
    create_certs "${certs_dir}" "${conf_dir}" "${vault_cert}"
}

main $@

