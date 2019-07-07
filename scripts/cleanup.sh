#!/usr/bin/env bash

. lib/functions.sh

# --- Main Function ------------------------------------------------------
main () {
    # main function vars/constants
    local -r certs_dir="certs"
    local -r vault_app_name="vault"
    local -r "vault_ns"="default"
    local -r consul_app_name="consul"
    local -r consul_ns="default"

    echo ""
    echo "--- Halting all port-forwarding ---"
    pkill kubectl

    echo ""
    echo "--- Deleting Deployment: vault ---"
    k8s_deployment_delete ${vault_app_name} ${vault_ns}

    echo ""
    echo "--- Deleting Service: vault ---"
    k8s_service_delete ${vault_app_name} ${vault_ns}

    echo ""
    echo "--- Deleting ConfigMap: vault ---"
    k8s_configmap_delete ${vault_app_name} ${vault_ns}

    echo ""
    echo "--- Deleting StatefulSet: consul ---"
    k8s_statefulset_delete ${consul_app_name} ${consul_ns}

    echo ""
    echo "--- Deleting Service: consul ---"
    k8s_service_delete ${consul_app_name} ${consul_ns}

    echo ""
    echo "--- Deleting ConfigMap: consul ---"
    k8s_configmap_delete ${consul_app_name} ${consul_ns}

    echo ""
    echo "--- Deleting PersistentVolumeClaims: consul ---"
    k8s_pvc_delete ${consul_app_name} ${consul_ns}

    echo ""
    echo "--- Deleting K8s secrets ---"
    for secret in ${vault_app_name} ${consul_app_name}
    do
        k8s_secret_delete ${secret}
    done

    if [[ -d ${certs_dir} ]]; then
        echo ""
        echo "--- Deleting certificates ---"
        rm -rfv ${certs_dir}
    fi
}

main $@

