#!/usr/bin/env bash

set -e


# --- K8s Helper Functions -----------------------------------------------

# DESC: generates gossip protocol encryption key
# ARGS: $1 (REQ): certificates directory path
#       $2 (REQ): application name
#       $3 (OPT): namespace
# OUT:  NONE
gossip_encryption_key() {
    # set namespace
    if [[ -z $3+x ]]; then
        local ns="default"
    else
        local ns="${3}"
    fi

    # Run K8s command
    if ! kubectl get secrets -n ${ns} | grep ${2} &> /dev/null; then
        export GOSSIP_ENCRYPTION_KEY=$(consul keygen)

        kubectl create secret generic ${2} -n ${ns} \
            --from-literal="gossip-encryption-key=${GOSSIP_ENCRYPTION_KEY}" \
            --from-file=${1}/ca.pem \
            --from-file=${1}/${2}.pem \
            --from-file=${1}/${2}-key.pem
        success "Create: gossip encryption key"
    else
        info "Already created: gossip encryption key"
    fi

    # Check K8s comand sanity
    info "Testing to see if the gossip encryption key is sane..."
    if ! kubectl describe secret ${2} -n ${ns} &> /dev/null; then
        substep_error "ERROR: can NOT find the gossip encryption key!"
        exit 1
    else
        substep_info "Gossip encryption key looks good"
    fi
}

# DESC: creates a K8s ConfigMap
# ARGS: $1 (REQ): application name
#       $2 (OPT): namespace
# OUT:  NONE
k8s_configmap() {
    # Set namespace
    if [ -z ${2+x} ]; then
        local ns="default"
    else
        local ns="${2}"
    fi

    # Run K8s command
    if ! kubectl get configmaps -n ${ns} | grep ${1} &> /dev/null; then
        kubectl create configmap ${1} -n ${ns} --from-file=${1}/config.json
        success "Created ConfigMap: ${1}"
    else
        info "Already created ConfigMap: ${1}"
    fi

    # Check K8s comand sanity
    info "Testing to see if ConfigMap: ${1} is sane..."
    if ! kubectl describe configmap ${1} -n ${ns} &> /dev/null; then
        substep_error "ERROR: can NOT file ConfigMap: ${1}!"
        exit 1
    else
        substep_info "ConfigMap: ${1} looks good"
    fi
}


# DESC: performs port-forwarding in the background
# ARGS: #1 (REQ): pod name
#       $2 (REQ): local port
#       $3 (REQ): pod port
#       $4 (OPT): namespace
# OUT:  None
k8s_port_forwarding() {
    # Set namespace
    if [ -z ${4+x} ]; then
        local ns="default"
    else
        local ns="${4}"
    fi

    # Run K8s command
    if ! ps aux | grep "[k]ubectl -n ${ns} port-forward" | grep ${1} &> /dev/null; then
        kubectl -n ${ns} port-forward ${1} ${2}:${3} &
        success "${1} - forwarding local port: ${2} to pod port: ${3}"
    else
        info "${1} - already forwarding local port: ${2} to pod port: ${3}"
    fi

    # Check K8s command sanity
    info "Testing to see if ${1} - forwarding pod port: ${3} is sane..."
    if ! ps aux | grep "[k]ubectl -n ${ns} port-forward" | grep ${1} | grep ${2} &> /dev/null; then
        substep_error "ERROR: can NOT forward ${1} - pod port: ${3}"
    else
        substep_info "${1} - forwarding pod port: ${3} looks good"
    fi
}


# DESC: creates a K8s StatefulSet
# ARGS: $1 (REQ): application name
#       $2 (OPT): namespace
# OUT:  NONE
k8s_statefulset() {
    # Set namespace
    if [ -z $2+x} ]; then
        local ns="default"
    else
        local ns="${2}"
    fi

    # Run K8s command
    if ! kubectl get pods -n ${ns} | grep ${1} &> /dev/null; then
        kubectl create -n ${ns} -f ${1}/statefulset.yaml &> /dev/null
        success "Created StatefulSet: ${1}"

        substep_info "Waiting for ${1} pods to launch..."
        sleep 15

        POD=${1}-1
        while true
        do
            STATUS=$(kubectl get pods ${POD} -n ${ns} -o jsonpath="{.status.phase}")

            if [[ "$STATUS" == "Running" ]]; then
                substep_info "Pod status: RUNNING"
                break
            else
                substep_info "Pod status: ${STATUS}"
                sleep 5
            fi
        done
    else
        info "Already created StatefulSet: ${1}"
    fi

    # Check K8s sanity
    info "Testing to see if StatefulSet: ${1} is sane..."
    if ! kubectl get pods -n ${ns} | grep ${1} &> /dev/null; then
        substep_error "ERROR: can NOT file Pods for: ${1}!"
        exit 1
    else
        substep_info "Pods for: ${1} look good"
    fi
}


# --- Pretty Print Helper Functions --------------------------------------

# DESC: pretty printing functions inspired from
#       https://github.com/Sajjadhosn/dotfiles
# ARGS: $1 (REQ): string text message
#       $2 (REQ): text color
#       $3 (REQ): arrow (string representation)
# OUT:  NONE
coloredEcho() {
    # function vars/constants
    local color="${2}"

    if ! [[ ${color} =~ '^[0-9]$' ]]; then
        case $(echo ${color} | tr '[:upper:]' '[:lower:]') in
            black)   color=0 ;;
            red)     color=1 ;;
            green)   color=2 ;;
            yellow)  color=3 ;;
            blue)    color=4 ;;
            magenta) color=5 ;;
            cyan)    color=6 ;;
            white|*) color=7 ;;
        esac
    fi

    tput bold
    tput setaf "${color}"
    echo "${3} ${1}"
    tput sgr0
}


# DESC: prints an error message
# ARGS: $1: string text message
# OUT:  printed string message
error() {
    coloredEcho "${1}" red "========>"
}


# DESC: prints an info message
# ARGS: $1: string text message
# OUT:  printed string message
info() {
    coloredEcho "${1}" blue "========>"
}


# DESC: prints a success message
# ARGS: $1: string text message
# OUT:  printed string message
success() {
    coloredEcho "${1}" green "========>"
}


# DESC: prints a substep error message
# ARGS: $1: string text message
# OUT:  printed string message
substep_error() {
    coloredEcho "${1}" red "===="
}


# DESC: prints a substep info message
# ARGS: $1: string text message
# OUT:  printed string message
substep_info() {
    coloredEcho "${1}" magenta "===="
}


# DESC: prints a substep success message
# ARGS: $1: string text message
# OUT:  printed string message
substep_success() {
    coloredEcho "${1}" cyan "===="
}

