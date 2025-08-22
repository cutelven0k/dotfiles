#!/usr/bin/env bash

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
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
    echo -e "${GREEN}Usage:${NC} $(basename $0) [location]"
    echo -e "Get the current weather for the specified location."
    echo -e ""
    echo -e "${GREEN}Options:${NC}"
    echo -e "   --verbose     Enable verbose mode for debug messages."
    echo -e "   --help        Show this help message."
    echo -e ""
    echo -e "${GREEN}Example:${NC}"
    echo -e "   $(basename $0) NewYork"
    echo -e "   $(basename $0) --verbose London"
}

if (( HELP )) || [ ${#ARGS[@]} -eq 0 ]; then
    print_help
    exit 0
fi

check_dependencies() {
    if (( VERBOSE )); then
        check_package.sh --verbose sed curl || exit 1
    else
        check_package.sh sed curl || exit 1
    fi
}

check_dependencies

for i in {1..5}
do
    if (( VERBOSE )); then
        echo -e "${YELLOW}Attempt $i to fetch weather for $1...${NC}"
    fi

    if ! curl -s --head https://wttr.in &>/dev/null; then
        ((VERBOSE)) && echo -e "${RED}No internet connection${NC}"
        exit 1
    fi

    text=$(curl -s "https://wttr.in/${ARGS[0]}?format=1")
    if [[ $? == 0 ]]; then
        text=$(echo "$text" | sed -E "s/\s+/ /g")

        tooltip=$(curl -s "https://wttr.in/${ARGS[0]}?format=4")
        if [[ $? == 0 ]]; then
            tooltip=$(echo "$tooltip" | sed -E "s/\s+/ /g")
            echo "{\"text\":\"$text\", \"tooltip\":\"$tooltip\"}"
            exit
        else
            ((VERBOSE)) && echo -e "${RED}Failed to get tooltip data${NC}"
            exit 1
        fi
    fi
    sleep 2
done
((VERBOSE)) && echo -e "{\"text\":\"error\", \"tooltip\":\"error\"}"
