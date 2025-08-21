#!/bin/bash

GREEN="\033[0;32m"
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
    echo -e "${GREEN}Usage:${NC} $(basename $0)"
    echo -e "Detects the current active keyboard layout and outputs a corresponding layout code."
    echo -e ""
    echo -e "${GREEN}Options:${NC}"
    echo -e "  --verbose     Enable verbose mode to print debug messages."
    echo -e "  --help        Show this help message."
    echo -e ""
    echo -e "${GREEN}Example:${NC}"
    echo -e "  $(basename $0) --verbose"
}

if (( HELP )); then
    print_help
    exit 0
fi

check_dependencies() {
    if (( VERBOSE )); then
        check_package.sh --verbose hyprland jq || exit 1
    else
        check_package.sh hyprland jq || exit 1
    fi
}

check_dependencies

layout=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap')

if [ -z "$layout" ]; then
    (( VERBOSE )) && echo -e "${RED}Could not detect active keyboard layout.${NC}"
    exit 1
fi

if (( VERBOSE )); then
    echo -e "${GREEN}Detected keyboard layout: $layout${NC}"
fi

case "$layout" in
    "English (US)") 
        echo "us" 
        ;;
    "Russian") 
        echo "ru" 
        ;;
    *) 
        echo "$layout" | tr '[:upper:]' '[:lower:]' 
        ;;
esac
