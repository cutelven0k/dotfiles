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
    echo -e "Select and apply a random wallpaper from the specified directory."
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
        check_package.sh --verbose imagemagick wofi hyprlock findutils coreutils || exit 1
    else
        check_package.sh imagemagick wofi hyprlock findutils coreutils || exit 1
    fi
}

check_dependencies

WALLPAPER_DIR="$HOME/.config/wallpapers"
THUMBNAIL_DIR="$HOME/.config/wallpapers_thumbnails"
CURRENT_WALLPAPER="$HOME/.config/.current_wallpaper"

if [ ! -d "$WALLPAPER_DIR" ]; then
    (( VERBOSE )) && echo -e "${RED}Wallpaper directory does not exist. Please ensure the directory is present.${NC}"
    exit 1
else
    (( VERBOSE )) && echo -e "${GREEN}Wallpaper directory exists: $WALLPAPER_DIR${NC}"
fi

if [ ! -d "$THUMBNAIL_DIR" ]; then
    (( VERBOSE )) && echo -e "${YELLOW}Thumbnail directory does not exist. Creating it now...${NC}"
    mkdir -p "$THUMBNAIL_DIR"
    (( VERBOSE )) && echo -e "${GREEN}Thumbnail directory created: $THUMBNAIL_DIR${NC}"
else
    (( VERBOSE )) && echo -e "${GREEN}Thumbnail directory exists: $THUMBNAIL_DIR${NC}"
fi

wallpapers=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -printf "%P\n")

if [ -z "$wallpapers" ]; then
    (( VERBOSE )) && echo -e "${RED}No valid wallpaper images found in $WALLPAPER_DIR. Please add some wallpapers.${NC}"
    exit 1
else
    (( VERBOSE )) && echo -e "${GREEN}Found valid wallpapers in $WALLPAPER_DIR${NC}"
fi

IFS=$'\n' read -rd '' -a wallpaper_array <<<"$wallpapers"

for wallpaper in "${wallpaper_array[@]}"; do
    thumbnail="${THUMBNAIL_DIR}/${wallpaper%.*}_thumbnail.${wallpaper##*.}"
    
    if [ -f "$thumbnail" ]; then
    
        thumbnail_size=$(identify -format "%wx%h" "$thumbnail")
        if [[ "$thumbnail_size" == 256x* ]]; then
            (( VERBOSE )) && echo -e "${GREEN}Thumbnail for $wallpaper exists and is 256px wide.${NC}"
        else
            (( VERBOSE )) && echo -e "${YELLOW}Thumbnail for $wallpaper exists but does not have the correct size ($thumbnail_size). Regenerating...${NC}"
            mkdir -p "$(dirname "$thumbnail")"
            magick "$WALLPAPER_DIR/$wallpaper" -thumbnail 256x256 "$thumbnail"
            (( VERBOSE )) && echo -e "${GREEN}Thumbnail regenerated for $wallpaper.${NC}"
        fi
    else
        (( VERBOSE )) && echo -e "${YELLOW}Thumbnail for $wallpaper does not exist. Creating...${NC}"
        mkdir -p "$(dirname "$thumbnail")"
        magick "$WALLPAPER_DIR/$wallpaper" -thumbnail 256x256 "$thumbnail"
        (( VERBOSE )) && echo -e "${GREEN}Thumbnail created for $wallpaper.${NC}"
    fi
done

relative_thumbnail_path=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -printf "%P\n" | while read -r file; do
    expected_thumbnail="${file%.*}_thumbnail.${file##*.}"
    echo "$expected_thumbnail"
done)

for thumbnail in $(find "$THUMBNAIL_DIR" -type f -printf "%P\n"); do
    if ! echo "$relative_thumbnail_path" | grep -qx "$thumbnail"; then
        (( VERBOSE )) && echo -e "${RED}Removing orphaned thumbnail: $thumbnail${NC}"
        rm -f "$THUMBNAIL_DIR/$thumbnail"
        (( VERBOSE )) && echo -e "${GREEN}Orphaned thumbnail removed: $thumbnail${NC}"
    fi
done

wallpapers_with_thumbnails="text:🎲 Random Wallpaper"
for wallpaper in "${wallpaper_array[@]}"; do
    thumbnail="${wallpaper%.*}_thumbnail.${wallpaper##*.}"
    full_thumbnail_path="${THUMBNAIL_DIR}/${thumbnail}"
    
    wallpapers_with_thumbnails="$wallpapers_with_thumbnails\nimg:$full_thumbnail_path:text:${wallpaper}"
done

selected_wallpaper=$(echo -e "$wallpapers_with_thumbnails" | wofi -I --dmenu -Dimage_size=125 --sort-order=alphabetical)
selected_wallpaper=$(echo "$selected_wallpaper" | awk -F'text:' '{print $2}')

if [ -n "$selected_wallpaper" ]; then
    if [[ "$selected_wallpaper" == "🎲 Random Wallpaper" ]]; then
        select_random_wallpaper.sh
        exit 0
    else
        selected_filename="$selected_wallpaper"
    fi

    wallpaper_path=$(find "$WALLPAPER_DIR" -type f -iwholename "$WALLPAPER_DIR/$selected_filename" | head -n 1)

    if [ -n "$wallpaper_path" ]; then
    
        cp "$wallpaper_path" "$CURRENT_WALLPAPER"

    
        (( VERBOSE )) && echo -e "${YELLOW}Applying selected wallpaper...${NC}"
        hyprctl hyprpaper preload "$wallpaper_path"
        hyprctl hyprpaper wallpaper ,"$wallpaper_path"
        (( VERBOSE )) && echo -e "${GREEN}Wallpaper applied successfully.${NC}"
    else
        (( VERBOSE )) && echo -e "${RED}Error: Wallpaper file not found.${NC}"
    fi
fi
