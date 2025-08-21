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
    echo -e "${GREEN}Usage:${NC} $(basename $0) [--nxt | --prv | --pause | --help]"
    echo -e "Controls music playback with mpc."
    echo -e ""
    echo -e "${GREEN}Options:${NC}"
    echo -e "  --nxt         Play the next track."
    echo -e "  --prv         Play the previous track."
    echo -e "  --pause       Toggle play/pause."
    echo -e "  --verbose     Enable verbose mode to print debug messages."
    echo -e "  --help        Show this help message."
    echo -e ""
    echo -e "${GREEN}Example:${NC}"
    echo -e "  $(basename $0) --nxt"
}

if (( HELP )); then
    print_help
    exit 0
fi

check_dependencies() {
    if (( VERBOSE )); then
        check_package.sh --verbose mpc || exit 1
    else
        check_package.sh mpc || exit 1
    fi
}

check_dependencies

play_next() {
    if (( VERBOSE )); then
        echo -e "${GREEN}Playing the next track...${NC}"
    fi
    mpc next
}

play_previous() {
    if (( VERBOSE )); then
        echo -e "${GREEN}Playing the previous track...${NC}"
    fi
    mpc prev
}

toggle_play_pause() {
    if (( VERBOSE )); then
        echo -e "${GREEN}Toggling play/pause...${NC}"
    fi
    mpc toggle
}

case "${ARGS[0]}" in
    "--nxt")
        play_next
        ;;
    "--prv")
        play_previous
        ;;
    "--pause")
        toggle_play_pause
        ;;
    *)
        print_help
        exit 1
        ;;
esac
