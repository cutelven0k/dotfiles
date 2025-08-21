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
    echo -e "Stops media playback, terminates mpv process, pauses mpc, and locks the screen."
    echo -e ""
    echo -e "${GREEN}Options:${NC}"
    echo -e "   --verbose     Enable verbose mode to print debug messages."
    echo -e "   --help        Show this help message."
    echo -e ""
    echo -e "${GREEN}Example:${NC}"
    echo -e "   $(basename $0) --verbose"
}

if (( HELP )); then
    print_help
    exit 0
fi

check_dependencies() {
    if (( VERBOSE )); then
        check_package.sh --verbose procps-ng playerctl mpc hyprlock || exit 1
    else
        check_package.sh procps-ng playerctl mpc hyprlock || exit 1
    fi
}

check_dependencies

if (( VERBOSE )); then
    echo -e "${GREEN}Stopping media playback, terminating mpv, pausing mpc, and locking the screen...${NC}"
fi

playerctl stop
if (( VERBOSE )); then
    echo -e "${GREEN}Stopped media playback using playerctl.${NC}"
fi

pkill -SIGTERM mpv
if (( VERBOSE )); then
    echo -e "${GREEN}Terminated mpv process with SIGTERM.${NC}"
fi

mpc pause
if (( VERBOSE )); then
    echo -e "${GREEN}Paused mpc playback.${NC}"
fi

hyprlock
if (( VERBOSE )); then
    echo -e "${GREEN}Locked the screen with hyprlock.${NC}"
fi
