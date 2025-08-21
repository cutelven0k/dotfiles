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
    echo -e "Generate a short conventional commit message from staged changes."
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
        check_package.sh --verbose tgpt git || exit 1
    else
        check_package.sh tgpt git || exit 1
    fi
}

check_dependencies

git rev-parse --is-inside-work-tree &>/dev/null || {
    (( VERBOSE )) && echo -e "${RED}Not a git repository.${NC}"
    exit 1
}

diff=$(git diff --staged)
if [ -z "$diff" ]; then
    (( VERBOSE )) && echo -e "${RED}No staged changes to commit.${NC}"
    exit 1
fi

if (( VERBOSE )); then
    echo -e "${GREEN}Staged changes detected!${NC}"
fi

tgpt --provider pollinations "short conventional commit message, no extra explanation: $diff"
