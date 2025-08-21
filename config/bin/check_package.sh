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
    echo -e "${GREEN}Usage:${NC} $(basename $0) [OPTIONS] <packages>"
    echo -e "Check if the specified packages are installed."
    echo -e ""
    echo -e "${GREEN}Options:${NC}"
    echo -e "   --verbose     Enable verbose mode to print debug messages."
    echo -e "   --help        Show this help message."
    echo -e ""
    echo -e "${GREEN}Example:${NC}"
    echo -e "   $(basename $0) --verbose libnotify"
}

check_package() {
    local pkg="$1"
    if (( VERBOSE )); then
        echo -e "${YELLOW}Checking package: $pkg...${NC}"
    fi

    if pacman -Qi "$pkg" &>/dev/null; then
        (( VERBOSE )) && echo -e "${GREEN}Package $pkg is installed.${NC}"
        return 0  
    else
        if pacman -Ss "$pkg" &>/dev/null; then
            (( VERBOSE )) && echo -e "${RED}Package $pkg is not installed, but is available in the pacman repositories.${NC}"
        else
            (( VERBOSE )) && echo -e "${RED}Package $pkg is not found in the pacman repositories.${NC}"
        fi
        return 1
    fi
}


if (( HELP )) || [ ${#ARGS[@]} -eq 0 ]; then
    print_help
    exit 0
fi

for package in "${ARGS[@]}"; do
    check_package "$package"
done
