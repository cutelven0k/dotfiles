#!/usr/bin/env sh

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
    echo -e "Fetch album art of the currently playing song and send a notification."
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
        check_package.sh --verbose coreutils rmpc libnotify || exit 1
    else
        check_package.sh coreutils rmpc libnotify || exit 1
    fi
}

check_dependencies

TMP_DIR="/tmp/rmpc"
mkdir -p "$TMP_DIR"
ALBUM_ART_PATH="$TMP_DIR/album_cover"
DEFAULT_ALBUM_ART_PATH="$HOME/.config/images/sound.png"

if ! rmpc albumart --output "$ALBUM_ART_PATH"; then
    ALBUM_ART_PATH="${DEFAULT_ALBUM_ART_PATH}"
    if (( VERBOSE )); then
        echo -e "${RED}No album art found, using fallback.${NC}"
    fi
fi

if (( VERBOSE )); then
    echo -e "${GREEN}Sending notification...${NC}"
fi
notify-send -i "${ALBUM_ART_PATH}" "Now Playing" "$ARTIST - $TITLE"
