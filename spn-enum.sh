#!/bin/bash

# Function to display usage
usage() {
    echo "SPN Enumeration Script for Active Directory"
    echo ""
    echo "This script automates the enumeration of Service Principal Names (SPNs) using GetUserSPNs.py from the Impacket suite."
    echo "You can specify a domain, domain controller IP, and a file containing usernames to quickly enumerate users."
    echo ""
    echo "Usage: $0 -d DOMAIN -u USERFILE -i DC_IP [-p PASSWORD] [-no-pass]"
    echo ""
    echo "Options:"
    echo "  -d DOMAIN        The domain to target (e.g., domain.local)."
    echo "  -u USERFILE      The file containing the list of usernames."
    echo "  -i DC_IP         The IP address of the Domain Controller."
    echo "  -p PASSWORD      Optional: The password for the account (if required)."
    echo "  -no-pass         Optional: Use this flag if no password is required (default)."
    echo ""
    echo "Example:"
    echo "  $0 -d domain.local -u usernames.txt -i dc-ip -no-pass"
    echo "  $0 -d domain.local -u usernames.txt -i dc-ip -p 'Password123'"
    echo ""
    echo "Additional Information:"
    echo "  - Ensure Impacket's GetUserSPNs.py is installed and available in your path."
    echo "  - The script reads usernames from a file (USERFILE) and iterates over each user."
    echo "  - If -no-pass is not specified, you can provide a password with -p."
    exit 1
}

# Initialize variables
password=""
no_pass=false

# Parse command-line arguments
while [[ "$1" != "" ]]; do
    case $1 in
        -d ) shift
             domain=$1
             ;;
        -u ) shift
             userfile=$1
             ;;
        -i ) shift
             dc_ip=$1
             ;;
        -p ) shift
             password=$1
             ;;
        -no-pass ) 
             no_pass=true
             ;;
        * ) usage
            exit 1
    esac
    shift
done

# Check if required arguments are set
if [ -z "$domain" ] || [ -z "$userfile" ] || [ -z "$dc_ip" ]; then
    usage
fi

# Check if user file exists
if [ ! -f "$userfile" ]; then
    echo "Error: User file '$userfile' not found!"
    exit 1
fi

# Loop through each username in the file and run GetUserSPNs.py
while IFS= read -r username; do
    if [ -n "$password" ]; then
        echo "Enumerating SPNs for user: $username with password"
        GetUserSPNs.py "$domain/$username:$password" -dc-ip "$dc_ip"
    elif [ "$no_pass" = true ]; then
        echo "Enumerating SPNs for user: $username with no password"
        GetUserSPNs.py "$domain/$username" -dc-ip "$dc_ip" -no-pass
    else
        echo "Enumerating SPNs for user: $username without password"
        GetUserSPNs.py "$domain/$username" -dc-ip "$dc_ip"
    fi
done < "$userfile"
