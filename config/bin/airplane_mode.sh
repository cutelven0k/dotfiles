#!/bin/bash

GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m"

NOTIF="$HOME/.config/images/airplane.png"
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
    echo -e "${GREEN}Usage:${NC} $(basename $0) [OPTIONS] [toggle|status]"
    echo -e "Toggle airplane mode or print the current status."
    echo -e ""
    echo -e "${GREEN}Options:${NC}"
    echo -e "   --verbose     Enable verbose mode to print debug messages."
    echo -e "   --help        Show this help message."
    echo -e ""
    echo -e "${GREEN}Commands:${NC}"
    echo -e "   toggle        Toggle the airplane mode (block/unblock all devices)."
    echo -e "                 This will enable or disable the airplane mode by"
    echo -e "                 blocking or unblocking all devices (WiFi, Bluetooth, etc.)."
    echo -e "   status        Print the current status of the airplane mode."
    echo -e "                 It shows whether the airplane mode is ON (all devices blocked)"
    echo -e "                 or OFF (all devices unblocked)."
    echo -e ""
    echo -e "${GREEN}Example:${NC}"
    echo -e "   $(basename $0) --verbose toggle"
}

check_dependencies() {
    if (( VERBOSE )); then
        check_package.sh --verbose rfkill libnotify || exit 1
    else
        check_package.sh rfkill libnotify || exit 1
    fi
}

toggle() {
    local devices_blocked
    devices_blocked=$(rfkill list | grep -o "Soft blocked: yes")

    if [ -n "$devices_blocked" ]; then
        (( VERBOSE )) && echo -e "${YELLOW}Some devices are currently blocked. Unblocking all...${NC}"
        rfkill unblock all
        notify-send -i "$NOTIF" "Airplane" "mode: OFF"
        (( VERBOSE )) && echo -e "${GREEN}Airplane mode disabled (all devices unblocked).${NC}"
    else
        (( VERBOSE )) && echo -e "${YELLOW}All devices are currently unblocked. Blocking all...${NC}"
        rfkill block all
        notify-send -i "$NOTIF" "Airplane" "mode: ON"
        (( VERBOSE )) && echo -e "${GREEN}Airplane mode enabled (all devices blocked).${NC}"
    fi
}

print_status() {
    local devices_blocked
    devices_blocked=$(rfkill list | grep -o "Soft blocked: yes")

    if [ -n "$devices_blocked" ]; then
        (( VERBOSE )) && echo -e "${RED}Airplane mode is ON (all devices blocked).${NC}"
        echo '{"alt": "off"}'
    else
        (( VERBOSE )) && echo -e "${GREEN}Airplane mode is OFF (all devices unblocked).${NC}"
        echo '{"alt": "on"}'
    fi
}

if (( HELP )) || [ ${#ARGS[@]} -eq 0 ]; then
    print_help
    exit 0
fi

check_dependencies

case "${ARGS[0]}" in
    toggle) toggle ;;
    status) print_status ;;
    *)      print_help ;;
esac
