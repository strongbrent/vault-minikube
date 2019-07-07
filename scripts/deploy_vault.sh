#!/usr/bin/env bash

. lib/functions.sh

# --- Main Function ------------------------------------------------------
main() {

    # main function vars/constants
    local -r certs_dir="certs"
    local -r app_name="vault"
    local -r vault_port=8200
    local -r vault_ns="default"

    echo ""
    echo "--- Storing certs in a Secret for: ${app_name} ---"
    k8s_store_certs ${certs_dir} ${app_name} ${vault_ns}

    echo ""
    echo "--- Creating ConfigMap for: ${app_name} ---"
    k8s_configmap ${app_name} ${vault_ns}

    echo ""
    echo "--- Creating Service for: ${app_name} ---"
    k8s_service ${app_name} ${consul_ns}

    echo ""
    echo "--- Creating Deployment for: ${app_name} ---"
    k8s_deployment ${app_name}

    local vault_pod=$(kubectl get pods -o=name | grep vault | sed "s/^.\{4\}//")

    echo ""
    echo "--- Forwarding port: ${vault_port} for: ${vault_pod} ---"
    k8s_port_forwarding ${vault_pod} ${vault_port} ${vault_port}
}

main $@

