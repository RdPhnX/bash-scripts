#!/usr/bin/env bash

# Interactive menu with arrow key navigation
# Usage: ./menu.sh "Select option" opt1 opt2 opt3 opt4

set -u

declare OPTIONS=()
declare PROMPT="Select an option:"
declare SELECTED=0
readonly SINGLE_SELECT_NAV_STRING=$'Navigation: \e[1;34m↑\e[0m/\e[1;34m↓\e[0m arrows to move, \e[1;34mEnter\e[0m to select\n'

# Save cursor position
save_cursor() {
    printf "\e[s"
}

# Restore cursor position
restore_cursor() {
    printf "\e[u"
}

# Clear from cursor to end of screen
clear_to_end() {
    printf "\e[J"
}

# Hide cursor
hide_cursor() {
    printf "\e[?25l"
}

# Show cursor
show_cursor() {
    printf "\e[?25h"
}

highlight() {
    printf "\e[7m%s\e[0m\n" "$1"
}

# Function to display the menu
display_menu() {
    # Save cursor position before drawing menu
    save_cursor

    # Clear any previous menu and redraw
    clear_to_end

    printf "%s:\n" "$PROMPT"

    for i in "${!OPTIONS[@]}"; do
        if ((i == SELECTED)); then
            highlight "[•] ${OPTIONS[$i]}"
        else
            printf "[ ] %s\n" "${OPTIONS[$i]}"
        fi
    done

    # Add navigation instructions
    printf "\n"
    printf "%s\n" "$SINGLE_SELECT_NAV_STRING"

    # Return to saved position
    restore_cursor
}

# Capture key presses
key_press() {
    local key
    IFS= read -rsn1 key 2>/dev/null >&2
    if [[ $key = $'\e' ]]; then
        read -rsn2 key
        case $key in
        '[A')
            echo "up"
            ;; # Up arrow
        '[B')
            echo "down"
            ;; # Down arrow
        *)
            echo "other"
            ;;
        esac
    elif [[ $key = "" ]]; then
        echo "enter"
    else
        echo "other"
    fi
}

# Main function
main() {
    PROMPT=$1
    readonly PROMPT
    shift
    OPTIONS=("$@")
    readonly OPTIONS
    local total=${#OPTIONS[@]}

    hide_cursor
    trap 'clear_to_end; show_cursor' EXIT # Ensure menu is cleared when script exits

    # Store current cursor position before displaying menu
    save_cursor

    # Display menu initially
    display_menu

    # Main loop
    while true; do
        # Get key press
        key=$(key_press)

        case $key in
        up)
            # Move selection up
            ((SELECTED--))
            if ((SELECTED < 0)); then
                SELECTED=$((total - 1))
            fi
            display_menu
            ;;
        down)
            # Move selection down
            ((SELECTED++))
            if ((SELECTED >= total)); then
                SELECTED=0
            fi
            display_menu
            ;;
        enter)
            # User pressed Enter, return the selected option
            # Move cursor to right after the prompt
            printf "\e[1B"
            show_cursor
            clear_to_end
            echo "You selected: ${OPTIONS[$SELECTED]}"
            exit 0
            ;;
        *)
            # Ignore other keys
            ;;
        esac
    done
}

main "$@"
