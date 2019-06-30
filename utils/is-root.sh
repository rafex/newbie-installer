#!/bin/bash
# Date: 29 June 2019
# Version: 0.1.0
# Written by: Raúl González <rafex.dev@gmail.com>

is_root () {
    return $(id -u)
}

has_sudo() {
    local prompt
    prompt=$(sudo -nv 2>&1)
    if [ $? -eq 0 ]; then
    return 0
    elif echo $prompt | grep -q '^sudo:'; then
    return 1
    else
    return 2
    fi
}
