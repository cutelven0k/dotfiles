#!/bin/bash

GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m"

check_package() {
    echo -e "${YELLOW}Checking package: $1...${NC}"

    if pacman -Qi "$1" &>/dev/null; then
        echo -e "${GREEN}Package $1 is installed.${NC}"
    else
        if pacman -Ss "$1" &>/dev/null; then
            echo -e "${RED}Package $1 is not installed, but is available in the pacman repositories. Please install it with 'pacman -S $1'.${NC}"
        else
            echo -e "${RED}Package $1 is not found in the pacman repositories.${NC}"
        fi
        return 1
    fi
}

if [ $# -eq 0 ]; then
    echo -e "${RED}No packages provided. Please specify packages to check.${NC}"
    exit 1
fi

for package in "$@"; do
    check_package "$package" || exit 1
done
