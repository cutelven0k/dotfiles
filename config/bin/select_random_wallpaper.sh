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
    echo -e "${GREEN}Usage:${NC} $(basename $0)"
    echo -e "Select a random wallpaper from the specified directory and apply it using hyprctl."
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
        check_package.sh --verbose hyprlock findutils coreutils || exit 1
    else
        check_package.sh hyprlock findutils coreutils || exit 1
    fi
}

check_dependencies

WALLPAPER_DIR="$HOME/.config/wallpapers"
CURRENT_WALLPAPER="$HOME/.config/.current_wallpaper"

if [ ! -d "$WALLPAPER_DIR" ]; then
    (( VERBOSE )) && echo -e "${RED}Wallpaper directory does not exist: $WALLPAPER_DIR${NC}"
    exit 1
else
    (( VERBOSE )) && echo -e "${GREEN}Wallpaper directory found: $WALLPAPER_DIR${NC}"
fi

wallpapers=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -printf "%P\n")

if [ -z "$wallpapers" ]; then
    (( VERBOSE )) && echo -e "${RED}No wallpapers found in $WALLPAPER_DIR.${NC}"
    exit 1
else
    (( VERBOSE )) && echo -e "${GREEN}Found wallpapers, selecting one at random...${NC}"
fi

random_wallpaper_rel=$(echo "$wallpapers" | shuf -n 1)
random_wallpaper="$WALLPAPER_DIR/$random_wallpaper_rel"

if [ -f "$random_wallpaper" ]; then
    (( VERBOSE )) && echo -e "${YELLOW}Randomly selected wallpaper:${NC} $random_wallpaper"

    cp "$random_wallpaper" "$CURRENT_WALLPAPER"
    
    (( VERBOSE )) && echo -e "${GREEN}Applying wallpaper via hyprctl...${NC}"
    hyprctl hyprpaper preload "$random_wallpaper"
    hyprctl hyprpaper wallpaper ,"$random_wallpaper"
    (( VERBOSE )) && echo -e "${GREEN}Wallpaper applied successfully.${NC}"
else
    (( VERBOSE )) && echo -e "${RED}Error: Selected wallpaper file does not exist: $random_wallpaper${NC}"
    exit 1
fi
