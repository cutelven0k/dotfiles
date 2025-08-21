#!/bin/bash

GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m"

VERBOSE=0
HELP=0
ARGS=()

for arg in "$@"; do
    case "$arg" in
        --verbose)
            VERBOSE=1
            ;;
        --help)
            HELP=1
            ;;
        *)
            ARGS+=("$arg")
            ;;
    esac
done

print_help() {
    echo -e "${GREEN}Usage:${NC} $(basename $0) [OPTIONS]"
    echo -e "Modify Tor bridges."
    echo -e ""
    echo -e "${GREEN}Options:${NC}"
    echo -e "   --verbose     Enable verbose mode to print debug messages."
    echo -e "   --help        Show this help message."
    echo -e ""
    echo -e "${GREEN}Example:${NC}"
    echo -e "   $(basename $0) --verbose"
}

check_dependencies() {
    if (( VERBOSE )); then
        check_package.sh --verbose wofi systemd tor || exit 1
    else
        check_package.sh wofi systemd tor || exit 1
    fi
}

is_valid_bridge() {

    if [[ "$1" =~ ^obfs4[[:space:]][0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+[[:space:]].*cert=[a-zA-Z0-9+/=]+.*iat-mode=[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

if (( HELP )); then
    print_help
    exit 0
fi

check_dependencies

if (( VERBOSE )); then
    echo -e "${YELLOW}Launching wofi to get input...${NC}"
fi
input=$(wofi -I --dmenu --height 1px)

if [ -z "$input" ]; then
    if (( VERBOSE )); then
        echo -e "${RED}Input is empty or canceled. Nothing changed.${NC}"
    fi
    exit 0
fi

IFS=$'\n' read -d '' -r -a lines <<< "$input"

for line in "${lines[@]}"; do

    if [ -n "$line" ] && ! is_valid_bridge "$line"; then
        if (( VERBOSE )); then
            echo -e "${RED}Invalid bridge format: $line. Exiting.${NC}"
        fi
        exit 1
    fi
done

if (( VERBOSE )); then
    echo -e "${YELLOW}Removing existing bridges from /etc/tor/torrc...${NC}"
fi
sudo sed -i '/^Bridge /d' /etc/tor/torrc

for line in "${lines[@]}"; do

    if [ -n "$line" ] && is_valid_bridge "$line"; then
        if (( VERBOSE )); then
            echo -e "${YELLOW}Adding bridge: $line${NC}"
        fi
        echo "Bridge $line" | sudo tee -a /etc/tor/torrc > /dev/null
    fi
done

if (( VERBOSE )); then
    echo -e "${YELLOW}Restarting Tor service...${NC}"
fi
sudo systemctl restart tor

if (( VERBOSE )); then
    echo -e "${GREEN}Bridges updated.${NC}"
fi
