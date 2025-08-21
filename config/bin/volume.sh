#!/bin/bash

GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m"

VERBOSE=0
HELP=0

for arg in "$@"; do
    case "$arg" in
        --verbose)
            VERBOSE=1
            ;;
        --help)
            HELP=1
            ;;
        *)
            ACTION="$arg"
            ;;
    esac
done

print_help() {
    echo -e "${GREEN}Usage:${NC} $(basename $0) {up|down|mute}"
    echo -e "Control the audio volume using pactl. This script can increase or decrease volume, or mute/unmute the audio."
    echo -e ""
    echo -e "${GREEN}Options:${NC}"
    echo -e "  --verbose     Enable verbose mode to print debug messages about current volume and mute status."
    echo -e "  --help        Show this help message."
    echo -e ""
    echo -e "${GREEN}Actions:${NC}"
    echo -e "  up            Increase the volume by 3%, up to 100%."
    echo -e "  down          Decrease the volume by 3%, down to 0%."
    echo -e "  mute          Toggle mute/unmute the audio."
    echo -e ""
    echo -e "${GREEN}Example Usage:${NC}"
    echo -e "  $(basename $0) up        # Increases the volume by 3%"
    echo -e "  $(basename $0) down      # Decreases the volume by 3%"
    echo -e "  $(basename $0) mute      # Toggles mute on/off"
    exit 0
}

if (( HELP )); then
    print_help
    exit 0
fi

check_dependencies() {
    if (( VERBOSE )); then
        check_package.sh --verbose pulseaudio gawk grep coreutils || exit 1
    else
        check_package.sh pulseaudio gawk grep coreutils || exit 1
    fi
}

check_dependencies

current_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1 | tr -d '%')
mute_status=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

if [[ -z "$current_volume" ]]; then
    (( VERBOSE )) && echo -e "${RED}Error: Failed to retrieve current volume.${NC}"
    exit 1
fi

if (( VERBOSE )); then
    (( VERBOSE )) && echo -e "${GREEN}Current volume: ${current_volume}%${NC}"
    (( VERBOSE )) && echo -e "${GREEN}Mute status: ${mute_status}${NC}"
fi

if [[ "$mute_status" == "yes" && "$ACTION" != "mute" ]]; then
    (( VERBOSE )) && echo -e "${YELLOW}Audio is muted. Unmute before adjusting volume.${NC}"
    exit 0
fi

case "$ACTION" in
    up)
        new_volume=$((current_volume + 3))
        (( new_volume > 100 )) && new_volume=100
        pactl set-sink-volume @DEFAULT_SINK@ "${new_volume}%"
        (( VERBOSE )) && echo -e "${GREEN}Volume increased to ${new_volume}%${NC}"
        ;;
    down)
        new_volume=$((current_volume - 3))
        (( new_volume < 0 )) && new_volume=0
        pactl set-sink-volume @DEFAULT_SINK@ "${new_volume}%"
        (( VERBOSE )) && echo -e "${YELLOW}Volume decreased to ${new_volume}%${NC}"
        ;;
    mute)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        mute_status=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
        if [[ "$mute_status" == "yes" ]]; then
            (( VERBOSE )) && echo -e "${YELLOW}Volume muted.${NC}"
        else
            (( VERBOSE )) && echo -e "${GREEN}Volume unmuted.${NC}"
        fi
        ;;
    *)
        print_help
        exit 1
        ;;
esac
