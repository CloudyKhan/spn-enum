#!/bin/bash

usage() {
    echo "SPN Enumeration Script"
    echo ""
    echo "Usage: $0 -d DOMAIN -u USERFILE -i DC_IP [-p PASSWORD] [-no-pass]"
    echo ""
    echo "Options:"
    echo "  -d DOMAIN        The domain (e.g., domain.local)"
    echo "  -u USERFILE      File with usernames"
    echo "  -i DC_IP         Domain Controller IP"
    echo "  -p PASSWORD      Password for the user (optional)"
    echo "  -no-pass         Use if there's no password (optional)"
    echo ""
    exit 1
}

# Defaults
password=""
no_pass=false

# Parse args
while [[ "$1" != "" ]]; do
    case $1 in
        -d ) shift; domain=$1 ;;
        -u ) shift; userfile=$1 ;;
        -i ) shift; dc_ip=$1 ;;
        -p ) shift; password=$1 ;;
        -no-pass ) no_pass=true ;;
        * ) usage ;;
    esac
    shift
done

# Check required args
if [[ -z "$domain" || -z "$userfile" || -z "$dc_ip" ]]; then
    usage
fi

# Check if user file exists
if [[ ! -f "$userfile" ]]; then
    echo "User file not found: $userfile"
    exit 1
fi

# Loop through users and run the SPN command
while IFS= read -r username; do
    if [[ -n "$password" ]]; then
        echo "Running for user: $username with password"
        GetUserSPNs.py "$domain/$username:$password" -dc-ip "$dc_ip"
    elif [[ "$no_pass" == true ]]; then
        echo "Running for user: $username with no password"
        GetUserSPNs.py "$domain/$username" -dc-ip "$dc_ip" -no-pass
    else
        echo "Running for user: $username without password"
        GetUserSPNs.py "$domain/$username" -dc-ip "$dc_ip"
    fi
done < "$userfile"
