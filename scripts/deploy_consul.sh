#!/usr/bin/env bash

. lib/functions.sh

# --- Main Function ------------------------------------------------------
main() {

    # main function vars/constants
    local -r certs_dir="certs"
    local -r app_name="consul"
    local -r consul_pod="consul-1"
    local -r consul_port="8500"
    local -r consul_ns="default"

    echo ""
    echo "--- Generating gossip encryption key ---"
    gossip_encryption_key ${certs_dir} ${app_name} ${consul_ns}

    echo ""
    echo "--- Creating ConfigMap for: ${app_name} ---"
    k8s_configmap ${app_name} ${consul_ns}

    echo ""
    echo "--- Creating Service for: ${app_name} ---"
    k8s_service ${app_name} ${consul_ns}

    echo ""
    echo "--- Creating StatefulSet for: ${app_name} ---"
    k8s_statefulset ${app_name} ${consul_ns}

    echo ""
    echo "--- Forwarding port: ${consul_port} for: ${consul_pod} ---"
    k8s_port_forwarding ${consul_pod} ${consul_port} ${consul_port} ${consul_ns}
}

main $@
