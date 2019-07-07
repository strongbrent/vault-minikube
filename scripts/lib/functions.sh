#!/usr/bin/env bash

# --- K8s Helper Functions -----------------------------------------------

# DESC: generates gossip protocol encryption key
# ARGS: $1 (REQ): certificates directory path
#       $2 (REQ): application name
#       $3 (OPT): namespace
# OUT:  NONE
gossip_encryption_key() {
    # set namespace
    local -r ns="${3:-default}"

    # Run K8s command
    if ! kubectl get secrets -n ${ns} | grep ${2} &> /dev/null; then
        export GOSSIP_ENCRYPTION_KEY=$(consul keygen)

        kubectl create secret generic ${2} -n ${ns} \
            --from-literal="gossip-encryption-key=${GOSSIP_ENCRYPTION_KEY}" \
            --from-file=${1}/ca.pem \
            --from-file=${1}/${2}.pem \
            --from-file=${1}/${2}-key.pem
        success "Created: gossip encryption key"
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
    local -r ns="${2:-default}"

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


# DESC: deletes a k8s ConfigMap
# ARGS: $1 (REQ): application name
#       $2 (OPT): namespace
# OUT:  NONE
k8s_configmap_delete() {
    # Set namespace
    local -r ns="${2:-default}"

    # Run K8s command
    if kubectl get configmaps -n ${ns} | grep ${1} &> /dev/null; then
        kubectl delete configmap -n ${ns} ${1} &> /dev/null
        success "Deleted ConfigMap: ${1}"
    else
        info "Already deleted ConfigMap: ${1}"
    fi
}


# DESC: creates a K8s Deployment
# ARGS: $1 (REQ): application name
#       $2 (OPT): namespace
# OUT:  NONE
k8s_deployment() {
    # Set namespace
    local -r ns="${2:-default}"

    # Run K8s command
    if ! kubectl get pods -n ${ns} | grep ${1} &> /dev/null; then
        kubectl apply -n ${ns} -f ${1}/deployment.yaml
        success "Applying Deployment for: ${1}"

        # Wait for pods to launch
        substep_info "Waiting for pods to launch for: ${1}"
        sleep 15

        POD=$(kubectl get pods -n ${ns} -o=name | grep ${1} | sed "s/^.\{4\}//")
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
        info "Already applied Deployment for: ${1}"
    fi

    # Check K8s command sanity
    info "Testing to see if Deployment: ${1} is sane..."
    if ! kubectl get pods -n ${ns} | grep ${1} &> /dev/null; then
        substep_error "ERROR: can NOT find Pods for: ${1}!"
        exit 1
    else
        substep_info "Pods for: ${1}: look good"
    fi
}


# DESC: deletes a K8s Deployment
# ARGS: $1 (REQ): application name
#       $2 (OPT): namespace
# OUT:  NONE
k8s_deployment_delete() {
    # Set namespace
    local -r ns="${2:-default}"

    # Run the K8s command
    if kubectl get pods -n ${ns} | grep ${1} &> /dev/null; then
        kubectl delete deployment ${1} -n ${ns} &> /dev/null
        success "Deleted Deployment for: ${1}"
    else
        info "Already deleted Deployment for: ${1}"
    fi
}


# DESC: performs port-forwarding in the background
# ARGS: #1 (REQ): pod name
#       $2 (REQ): local port
#       $3 (REQ): pod port
#       $4 (OPT): namespace
# OUT:  NONE
k8s_port_forwarding() {
    # Set namespace
    local -r ns="${4:-default}"

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


# DESC: deletes persistent volume claims
# ARGS: $1: (REQ): application name (label)
#       $2: (OPT): namespace
# OUT:  NONE
k8s_pvc_delete() {
    # Set namespace
    local -r ns="${2:-default}"

    # Run the K8s command
    if kubectl get pvc -n ${ns} | grep ${1} &> /dev/null; then
        substep_info "...this could take a few moments"
        kubectl delete pvc -n ${ns} -l app=${1} &> /dev/null
        success "Deleted persistemt volume claims for: ${1}"
    else
        info "Already deleted persistemt volume claims for: ${1}"
    fi
}


# DESC: deletes a K8s Secret
# ARGS: $1 (REQ): application name
#       $2 (OPT): namespace
# OUT:  NONE
k8s_secret_delete() {
    # Set namespace
    local -r ns="${2:-default}"

    # Run the K8s command
    if kubectl get secret ${1} -n ${ns} &> /dev/null; then
        kubectl delete secret ${1} -n ${ns} &> /dev/null
        success "Deleted Secret for: ${1}"
    else
        info "Already deleted Secret for: ${1}"
    fi
}


# DESC: creates a k8s Service
# ARGS: $1 (REQ): application name
#       $2 (OPT): namespace
# OUT:  NONE
k8s_service() {
    # Set namespace
    local -r ns="${2:-default}"

    # Run K8s command
    if ! kubectl get service ${1} -n ${ns} | grep ${1} &> /dev/null; then
        kubectl create -n ${ns} -f ${1}/service.yaml &> /dev/null
        success "Created Service: ${1}"
    else
        info "Already created Service: ${1}"
    fi

    # Check K8s command sanity
    info "Testing to see if Service: ${1} is sane..."
    if ! kubectl get service ${1} -n ${ns} &> /dev/null; then
        substep_error "ERROR: can NOT find Service: ${1}!"
    else
        substep_info "Service: ${1} looks good"
    fi
}


# DESC: deletes a k8s Service
# ARGS: $1 (REQ): application name
#       $2 (OPT): namespace
# OUT:  NONE
k8s_service_delete() {
    # Set namespace
    local -r ns="${2:-default}"

    # Run the K8s command
    if kubectl get service -n ${ns} | grep ${1} &> /dev/null; then
        kubectl delete service ${1} -n ${ns} &> /dev/null
        success "Deleted Service: ${1}"
    else
        info "Already deleted Service: ${1}"
    fi
}


# DESC: creates a K8s StatefulSet
# ARGS: $1 (REQ): application name
#       $2 (OPT): namespace
# OUT:  NONE
k8s_statefulset() {
    # Set namespace
    local -r ns="${2:-default}"

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
        substep_error "ERROR: can NOT find Pods for: ${1}!"
        exit 1
    else
        substep_info "Pods for: ${1} look good"
    fi
}


# DESC: deletes a k8s StatefulSet
# ARGS: $1 (REQ): application name
#       $2 (OPT): namespace
# OUT:  NONE
k8s_statefulset_delete() {
    # Set namespace
    local -r ns="${2:-default}"

    # Run K8s command
    if kubectl get pods -n ${ns} | grep ${1} &> /dev/null; then
        kubectl delete statefulset ${1} -n ${ns} &> /dev/null
        success "Deleted StatefulSet: ${1}"
    else
        info "Already deleted StatefulSet: ${1}"
    fi
}


# DESC: store K8s certificates in a Secret
# ARGS: $1 (REQ): certs dir
#       $2 (REQ): application name
#       $3 (OPT): namespace
# OUT:  NONE
k8s_store_certs() {
    # Set namespace
    local -r ns="${3:-default}"

    # Run K8s Command
    if ! kubectl get secrets -n ${ns} | grep ${2} &> /dev/null; then
        kubectl create secret generic ${2} -n ${ns} \
            --from-file=${1}/ca.pem \
            --from-file=${1}/${2}.pem \
            --from-file=${1}/${2}-key.pem
        success "Certs stored as a Secret for: ${2}"
    else
        info "Certs already stored as a Secret for: ${2}"
    fi

    # Check K8s command sanity
    info "Testing to see if storing certs as a Secret for: ${2} is sane..."
    if ! kubectl describe secret ${2} -n ${ns} &> /dev/null; then
        substep_error "ERROR: can NOT file Secret for: ${2}"
        exit 1
    else
        substep_info "Secret for: ${2} looks good"
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

