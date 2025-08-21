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
    echo -e "${GREEN}Usage:${NC} $(basename $0) [OPTIONS] [--critical|--full]"
    echo -e "Notify about battery status with custom images."
    echo -e ""
    echo -e "${GREEN}Options:${NC}"
    echo -e "   --verbose     Enable verbose mode to print debug messages."
    echo -e "   --help        Show this help message."
    echo -e ""
    echo -e "${GREEN}Commands:${NC}"
    echo -e "   --critical     Notify about low battery with critical urgency."
    echo -e "   --full         Notify about full battery with normal urgency."
    echo -e ""
    echo -e "${GREEN}Example:${NC}"
    echo -e "   $(basename $0) --verbose --critical"
}

check_dependencies() {
    if (( VERBOSE )); then
        check_package.sh --verbose libnotify || exit 1
    else
        check_package.sh libnotify || exit 1
    fi
}

critical() {
    critical_image="$HOME/.config/images/battery_empty.png"
    (( VERBOSE )) && echo -e "${YELLOW}Sending critical battery notification...${NC}"
    notify-send -i "$critical_image" -u critical "Low Battery!" "I am bad⚰️⚰️⚰️"
}

full() {
    full_image="$HOME/.config/images/battery_full.png"
    (( VERBOSE )) && echo -e "${YELLOW}Sending full battery notification...${NC}"
    notify-send -i "$full_image" "Battery Full!" "I am good✨✨✨"
}

if (( HELP )) || [ ${#ARGS[@]} -eq 0 ]; then
    print_help
    exit 0
fi

check_dependencies

case "${ARGS[0]}" in
    --critical)
        critical
        ;;
    --full)
        full
        ;;
    *)
        print_help
        exit 1
        ;;
esac
