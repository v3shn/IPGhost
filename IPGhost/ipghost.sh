#!/bin/bash

# ANSI color codes
RESET="\033[0m"
BOLD="\033[1m"
GREEN="\033[92m"
YELLOW="\033[93m"
RED="\033[91m"

# check if the user run as root or with sudo
check_sudo() {

   if [ "$EUID" -ne 0 ];then

        echo -e "${YELLOW} Please Run This Tool As Root Or With sudo${RESET}"

        exit 1

   fi 

 }

# Function to check and install dependencies
install_dependencies() {
    echo -e "${GREEN}[+] Checking dependencies...${RESET}"

    # Check and install Tor
    if ! command -v tor >/dev/null 2>&1; then
        echo -e "${RED}[!] Tor is not installed. Installing Tor...${RESET}"
        sudo apt update && sudo apt install tor -y
        echo -e "${GREEN}[+] Tor installed successfully.${RESET}"
    else
        echo -e "${GREEN}[+] Tor is already installed.${RESET}"
    fi

    # Check and install curl
    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${RED}[!] curl is not installed. Installing curl...${RESET}"
        sudo apt install curl -y
        echo -e "${GREEN}[+] curl installed successfully.${RESET}"
    else
        echo -e "${GREEN}[+] curl is already installed.${RESET}"
    fi

    # Check and install jq
    if ! command -v jq >/dev/null 2>&1; then
        echo -e "${RED}[!] jq is not installed. Installing jq...${RESET}"
        sudo apt install jq -y
        echo -e "${GREEN}[+] jq installed successfully.${RESET}"
    else
        echo -e "${GREEN}[+] jq is already installed.${RESET}"
    fi
}

# Display banner
display_banner() {
    clear
    echo -e "${GREEN}${BOLD}"
    cat << "EOF"
     
  _____ _____     _____ _               _   
 |_   _|  __ \   / ____| |             | |  
   | | | |__) | | |  __| |__   ___  ___| |_ 
   | | |  ___/  | | |_ | '_ \ / _ \/ __| __|
  _| |_| |      | |__| | | | | (_) \__ \ |_ 
 |_____|_|       \_____|_| |_|\___/|___/\__|

                         Developer: Sreeraj
                                                                        
EOF
    echo -e "${RESET}${YELLOW}* Copyright © Sreeraj, 2024  *"
    echo -e "${YELLOW}* GitHub: https://github.com/s-r-e-e-r-a-j  *${RESET}"
    echo
    echo -e "${GREEN}Change your SOCKS to 127.0.0.1:9050${RESET}"
    echo
}

# Start Tor service
initialize_tor() {
    echo -e "${GREEN}[+] Starting Tor service...${RESET}"
    sudo service tor start
    echo -e "${GREEN}[+] Tor service started.${RESET}"
}

# Rotate identity using Tor
rotate_identity() {
    echo -e "${YELLOW}[~] Changing identity...${RESET}"
    sudo service tor reload
    echo -e "${YELLOW}[~] Identity changed.${RESET}"
}

# Fetch external IP using Tor
fetch_ip() {
    local ip
    ip=$(curl --silent --socks5 127.0.0.1:9050 --socks5-hostname 127.0.0.1:9050 http://httpbin.org/ip | jq -r .origin 2>/dev/null)
    if [ -z "$ip" ]; then
        echo -e "${RED}Error: Unable to fetch IP.${RESET}"
    else
        echo "$ip"
    fi
}

# Main function for IP rotation
execute_rotation() {
    display_banner
    initialize_tor

    echo -ne "${YELLOW}[+] Enter interval (seconds) between IP changes [default: 60]: ${RESET}"
    read -r interval
    interval=${interval:-60}

    echo -ne "${YELLOW}[+] Enter number of IP changes (0 for infinite): ${RESET}"
    read -r cycles
    cycles=${cycles:-0}

    if [[ "$cycles" -eq 0 ]]; then
        echo -e "${GREEN}[+] Infinite mode activated. Press Ctrl+C to stop.${RESET}"
        while true; do
            sleep "$interval"
            rotate_identity
            echo -e "${GREEN}[+] New IP: $(fetch_ip)${RESET}"
        done
    else
        for ((i = 1; i <= cycles; i++)); do
            sleep "$interval"
            rotate_identity
            echo -e "${GREEN}[+] New IP: $(fetch_ip)${RESET}"
        done
    fi
}

#check if the user run as root or with sudo
check_sudo
# Ensure dependencies are installed and start the script
install_dependencies
execute_rotation
