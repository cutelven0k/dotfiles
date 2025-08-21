#!/bin/bash

GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m"

NOTIF="$HOME/.config/images/airplane.png"
VERBOSE=0
ARGS=()

for arg in "$@"; do
    case "$arg" in
        --verbose)
            VERBOSE=1
            ;;
        *)
            ARGS+=("$arg")
            ;;
    esac
done

if (( VERBOSE )); then
    check_package.sh --verbose rfkill libnotify || exit 1
else
    check_package.sh rfkill libnotify || exit 1
fi

toggle() {
    local wifi_blocked
    wifi_blocked=$(rfkill list wifi | grep -o "Soft blocked: yes")

    if [ -n "$wifi_blocked" ]; then
        (( VERBOSE )) && echo -e "${YELLOW}WiFi is currently blocked. Unblocking all...${NC}"
        rfkill unblock all
        notify-send -i "$NOTIF" "Airplane" "mode: OFF"
        (( VERBOSE )) && echo -e "${GREEN}Airplane mode disabled (WiFi unblocked).${NC}"
    else
        (( VERBOSE )) && echo -e "${YELLOW}WiFi is currently unblocked. Blocking all...${NC}"
        rfkill block all
        notify-send -i "$NOTIF" "Airplane" "mode: ON"
        (( VERBOSE )) && echo -e "${GREEN}Airplane mode enabled (WiFi blocked).${NC}"
    fi
}

print_status() {
    local wifi_blocked
    wifi_blocked=$(rfkill list wifi | grep -o "Soft blocked: yes")

    if [ -n "$wifi_blocked" ]; then
        (( VERBOSE )) && echo -e "${RED}Airplane mode is ON (WiFi blocked).${NC}"
        echo '{"alt": "off"}'
    else
        (( VERBOSE )) && echo -e "${GREEN}Airplane mode is OFF (WiFi unblocked).${NC}"
        echo '{"alt": "on"}'
    fi
}

case "${ARGS[0]}" in
    toggle) toggle ;;
    *)      print_status ;;
esac
