#!/usr/bin/env bash

set -e

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

